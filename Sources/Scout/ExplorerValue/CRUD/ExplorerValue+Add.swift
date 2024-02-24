//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Add

extension ExplorerValue {

    // MARK: PathExplorer

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        self = try _add(path: Slice(path), value: value)
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> ExplorerValue {
        try _add(path: Slice(path), value: value)
    }

    // MARK: General function

    /// Return the value if it should be added to the parent
    private func _add(path: SlicePath, value: ExplorerValue) throws -> Self {
        guard let (head, tail) = path.headAndTail() else { return value }

        return try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): return try add(key: key, value: value, tail: tail)
            case .index(let index): return try add(index: index, value: value, tail: tail)
            case .count: return try addCount(value: value, tail: tail)
            default: throw ExplorerError.wrongUsage(of: head)
            }
        }
    }

    // MARK: PathElement

    private func add(key: String, value: ExplorerValue, tail: SlicePath) throws -> ExplorerValue {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
        if tail.isEmpty, dict[key] == nil {
            dict[key] = value
        } else {
            dict[key] = try dict.jaroWinkler(key: key)._add(path: tail, value: value)
        }

        return .dictionary(dict)
    }

    private func add(index: Int, value: ExplorerValue, tail: SlicePath) throws -> ExplorerValue {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)

        if index == array.count {
            return try addCount(value: value, tail: tail)
        }

        let index = try Self.computeIndex(from: index, arrayCount: array.count)
        let newValue = try array[index]._add(path: tail, value: value)

        if tail.isEmpty {
            array.insert(newValue, at: index)
        } else {
            array[index] = newValue
        }
        return .array(array)
    }

    private func addCount(value: ExplorerValue, tail: SlicePath) throws -> ExplorerValue {
        guard tail.isEmpty else {
            throw ExplorerError.wrongUsage(of: .count)
        }
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        array.append(value)
        return .array(array)
    }
}
