//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

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
        if let existingValue = dict[key] {
            dict[key] = try existingValue._add(path: tail, value: value)
        } else {
            dict[key] = try createValueToAdd(value: value, path: tail)
        }

        return .dictionary(dict)
    }

    private func add(index: Int, value: ExplorerValue, tail: SlicePath) throws -> ExplorerValue {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)

        if index == array.count {
            return try addCount(value: value, tail: tail)
        }

        let index = try computeIndex(from: index, arrayCount: array.count)
        let newValue = try array[index]._add(path: tail, value: value)

        if array.allSatisfy(\.isSingle) {
            #warning("This behavior is the current one but is strange. A new PathElement should be offered to differentiate between insertion and modification")
            array.insert(newValue, at: index)
        } else {
            array[index] = newValue
        }
        return .array(array)
    }

    private func addCount(value: ExplorerValue, tail: SlicePath) throws -> ExplorerValue {
        if var array = self.array {
            let newValue = try createValueToAdd(value: value, path: tail)
            array.append(newValue)
            return .array(array)
        } else {
            return try createValueToAdd(value: value, path: [.count] + tail)
        }
    }
}

// MARK: - Helpers

extension ExplorerValue {

    private func createValueToAdd(value: ExplorerValue, path: SlicePath) throws -> ExplorerValue {
        guard let element = path.first else { return value }
        let tail = path.dropFirst()

        switch element {
        case .key(let key):
            var dict = DictionaryValue()
            dict[key] = try createValueToAdd(value: value, path: tail)
            return .dictionary(dict)

        case .index:
            var array = ArrayValue()
            try array.append(createValueToAdd(value: value, path: tail))
            return .array(array)

        case .count:
            var array = ArrayValue()
            try array.append(createValueToAdd(value: value, path: tail))
            return .array(array)

        default:
            assertionFailure("This case should be handled before in the _add function")
            throw ExplorerError.wrongUsage(of: element)
        }
    }
}
