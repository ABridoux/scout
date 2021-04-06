//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValue {

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        self = try add(path: Slice(path), value: value)
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> ExplorerValue {
        try add(path: Slice(path), value: value)
    }

    /// Return `true` if the path is empty
    private func add(path: SlicePath, value: ExplorerValue) throws -> Self {
        guard let element = path.first else { return value }
        let remainder = path.dropFirst()

        return try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key): return try add(key: key, value: value, remainder: remainder)
            case .index(let index): return try add(index: index, value: value, remainder: remainder)
            case .count: return try addCount(value: value, remainder: remainder)
            default: throw ExplorerError.wrongUsage(of: element)
            }
        }
    }

    private func createValueToAdd(value: ExplorerValue, path: SlicePath) throws -> ExplorerValue {
        guard let element = path.first else { return value }
        let remainder = path.dropFirst()

        switch element {
        case .key(let key):
            var dict = DictionaryValue()
            dict[key] = try createValueToAdd(value: value, path: remainder)
            return .dictionary(dict)

        case .index:
            var array = ArrayValue()
            array.append(try createValueToAdd(value: value, path: remainder))
            return .array(array)

        case .count:
            var array = ArrayValue()
            try array.append(createValueToAdd(value: value, path: remainder))
            return .array(array)

        default:
            throw ExplorerError.wrongUsage(of: element)
        }
    }

    private func add(key: String, value: ExplorerValue, remainder: SlicePath) throws -> ExplorerValue {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
        if let existingValue = dict[key] {
            dict[key] = try existingValue.add(path: remainder, value: value)
        } else {
            dict[key] = try createValueToAdd(value: value, path: remainder)
        }

        return .dictionary(dict)
    }

    private func add(index: Int, value: ExplorerValue, remainder: SlicePath) throws -> ExplorerValue {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        let index = try computeIndex(from: index, arrayCount: array.count)
        let newValue = try array[index].add(path: remainder, value: value)

        if remainder.isEmpty {
            #warning("This behavior is the current one but is strange. A new PathElement should be offered to differentiate between insertion and modification")
            array.insert(newValue, at: index)
        } else {
            array[index] = newValue
        }
        return .array(array)
    }

    private func addCount(value: ExplorerValue, remainder: SlicePath) throws -> ExplorerValue {
        if var array = self.array {
            let newValue = try createValueToAdd(value: value, path: remainder)
            array.append(newValue)
            return .array(array)
        } else {
            return try createValueToAdd(value: value, path: [.count] + remainder)
        }
    }
}