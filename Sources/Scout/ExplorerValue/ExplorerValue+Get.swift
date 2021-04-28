//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValue {

    // MARK: PathExplorer

    public func get(_ path: Path) throws -> Self {
        try _get(path: Slice(path))
    }

    // MARK: General function

    private func _get(path: SlicePath) throws -> Self {
        guard let (head, tail) = path.headAndTail() else { return self }

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
        try dictionary
            .unwrapOrThrow(.subscriptKeyNoDict)
            .getJaroWinkler(key: key)
            ._get(path: tail)
    }

    private func get(index: Int, tail: SlicePath) throws -> Self {
        let array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        let index = try computeIndex(from: index, arrayCount: array.count)
        return try array[index]._get(path: tail)
    }

    private func getCount(tail: SlicePath) throws -> Self {
        switch self {
        case .array(let array): return .int(array.count)
        case .dictionary(let dict): return .int(dict.count)
        default: throw ExplorerError.wrongUsage(of: .count)
        }
    }

    private func getKeysList(tail: SlicePath) throws -> Self {
        let keys = try array <^>
            dictionary
            .unwrapOrThrow(.wrongUsage(of: .keysList))
            .keys
            .sorted()
            .map(ExplorerValue.string)

        return try keys._get(path: tail)
    }

    private func getSlice(for bounds: Bounds, tail: SlicePath) throws -> Self {
        let array = try self.array.unwrapOrThrow(.wrongUsage(of: .slice(bounds)))
        let range = try bounds.range(arrayCount: array.count)
        return try self.array <^> array[range].map { try $0._get(path: tail) }
    }

    private func getFilter(with pattern: String, tail: SlicePath) throws -> Self {
        let regex = try NSRegularExpression(with: pattern)
        return try dictionary <^>
            dictionary
            .unwrapOrThrow(.wrongUsage(of: .filter(pattern)))
            .filter { regex.validate($0.key) }
            .mapValues { try $0._get(path: tail) }
    }
}
