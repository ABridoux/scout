//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValue {

    // MARK: PathExplorer

    public func get(_ path: Path) throws -> Self {
        try _get(path: Slice(path))
    }

    // MARK: General function

    /// - parameter detailedName: When `true`, the key name after a filter will be composed of the parent key followed by the child key
    private func _get(path: SlicePath) throws -> Self {
        guard let (head, tail) = path.cutHead() else { return self }

        return try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): return try get(key: key, tail: tail)
            case .index(let index): return try get(index: index, tail: tail)
            case .count: return try getCount(tail: tail)
            case .keysList: return try getKeysList(tail: tail)
            case .slice(let bounds): return try getSlice(for: bounds, tail: tail)
            case .filter(let pattern): return try getFilter(with: pattern, tail: tail)
            }
        }
    }

    // MARK: PathElement

    private func get(key: String, tail: SlicePath) throws -> Self {
        switch self {
        case .dictionary(let dict):
            return try dict.getJaroWinkler(key: key)._get(path: tail)

        default:
            throw ExplorerError.subscriptKeyNoDict
        }
    }

    private func get(index: Int, tail: SlicePath) throws -> Self {

        switch self {
        case .array(let array):
            let index = try computeIndex(from: index, arrayCount: array.count)
            return try array[index]._get(path: tail)

        default:
            throw ExplorerError.subscriptIndexNoArray
        }
    }

    private func getCount(tail: SlicePath) throws -> Self {
        switch self {
        case .array(let array): return .int(array.count)
        case .dictionary(let dict): return .int(dict.count)
        default:
            throw ExplorerError.wrongUsage(of: .count)
        }
    }

    private func getKeysList(tail: SlicePath) throws -> Self {
        switch self {
        case .dictionary(let dict): return try (array <^> dict.keys.sorted().map(ExplorerValue.string))._get(path: tail)

        default:
            throw ExplorerError.wrongUsage(of: .keysList)
        }
    }

    private func getSlice(for bounds: Bounds, tail: SlicePath) throws -> Self {
        switch self {
        case .array(let array):
            let range = try bounds.range(arrayCount: array.count)
            return try self.array <^> array[range].map { try $0._get(path: tail) }

        default:
            throw ExplorerError.wrongUsage(of: .slice(bounds))
        }
    }

    private func getFilter(with pattern: String, tail: SlicePath) throws -> Self {
        switch self {
        case .dictionary(let dict):
            let regex = try NSRegularExpression(with: pattern)
            return try dictionary <^> dict
                .filter { regex.validate($0.key) }
                .mapValues { try $0._get(path: tail) }

        default:
            throw ExplorerError.wrongUsage(of: .filter(pattern))
        }
    }
}
