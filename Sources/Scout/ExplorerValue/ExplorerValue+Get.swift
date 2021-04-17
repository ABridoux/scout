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
        guard let element = path.first else { return self }
        let remainder = path.dropFirst()

        return try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key): return try get(key: key, remainder: remainder)
            case .index(let index): return try get(index: index, remainder: remainder)
            case .count: return try getCount(remainder: remainder)
            case .keysList: return try getKeysList(remainder: remainder)
            case .slice(let bounds): return try getSlice(for: bounds, remainder: remainder)
            case .filter(let pattern): return try getFilter(with: pattern, remainder: remainder)
            }
        }
    }

    // MARK: PathElement

    private func get(key: String, remainder: SlicePath) throws -> Self {
        switch self {
        case .dictionary(let dict):
            return try dict.getJaroWinkler(key: key)._get(path: remainder)

        default:
            throw ExplorerError.subscriptKeyNoDict
        }
    }

    private func get(index: Int, remainder: SlicePath) throws -> Self {

        switch self {
        case .array(let array):
            let index = try computeIndex(from: index, arrayCount: array.count)
            return try array[index]._get(path: remainder)

        default:
            throw ExplorerError.subscriptIndexNoArray
        }
    }

    private func getCount(remainder: SlicePath) throws -> Self {
        switch self {
        case .array(let array): return .int(array.count)
        case .dictionary(let dict): return .int(dict.count)
        default:
            throw ExplorerError.wrongUsage(of: .count)
        }
    }

    private func getKeysList(remainder: SlicePath) throws -> Self {
        switch self {
        case .dictionary(let dict): return try (array <^> dict.keys.sorted().map(ExplorerValue.string))._get(path: remainder)

        default:
            throw ExplorerError.wrongUsage(of: .keysList)
        }
    }

    private func getSlice(for bounds: Bounds, remainder: SlicePath) throws -> Self {
        switch self {
        case .array(let array):
            let range = try bounds.range(arrayCount: array.count)
            return try self.array <^> array[range].map { try $0._get(path: remainder) }

        default:
            throw ExplorerError.wrongUsage(of: .slice(bounds))
        }
    }

    private func getFilter(with pattern: String, remainder: SlicePath) throws -> Self {

        switch self {
        case .dictionary(let dict):
            let regex = try NSRegularExpression(with: pattern)
            return try dictionary <^> dict
                .filter { regex.validate($0.key) }
                .mapValues { try $0._get(path: remainder) }

        default:
            throw ExplorerError.wrongUsage(of: .filter(pattern))
        }
    }
}
