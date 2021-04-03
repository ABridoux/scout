//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ValueType {

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        _ = try delete(path: Slice(path), deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> ValueType {
        var copy = self
        try copy.delete(path, deleteIfEmpty: deleteIfEmpty)
        return copy
    }

    /// Returns `true` if the end of the path is reached
    private mutating func delete(path: SlicePath, deleteIfEmpty: Bool) throws -> Bool {
        guard let element = path.first else { return true}
        let remainder = path.dropFirst()

        try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key): try delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty)
            case .index(let index): try delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty)
            case .filter(let pattern): try deleteFilter(with: pattern, remainder: remainder, deleteIfEmpty: deleteIfEmpty)
            default:
                throw ValueTypeError.wrongUsage(of: element)
            }
        }

        return false
    }

    private mutating func delete(key: String, remainder: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .dictionary(var dict):

            var value = try dict.getJaroWinkler(key: key)
            let shouldDelete = try value.delete(path: remainder, deleteIfEmpty: deleteIfEmpty)

            if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                dict.removeValue(forKey: key)
            } else {
                dict[key] = value
            }

            self = .dictionary(dict)

        case .filter(var dict):
            try dict.modifyEachValue { try $0.delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .filter(dict)

        case .slice(var array):
            try array.modifyEach { try $0.delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .slice(array)

        default:
            throw ValueTypeError.subscriptKeyNoDict
        }
    }

    private mutating func delete(index: Int, remainder: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .array(var array):
            let index = try computeIndex(from: index, arrayCount: array.count)
            var value = array[index]
            let shouldDelete = try value.delete(path: remainder, deleteIfEmpty: deleteIfEmpty)

            if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                array.remove(at: index)
            } else {
                array[index] = value
            }
            self = .array(array)

        case .slice(var array):
            try array.modifyEach { try $0.delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .slice(array)

        case .filter(var dict):
            try dict.modifyEachValue { try $0.delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .filter(dict)

        default:
            throw ValueTypeError.subscriptIndexNoArray
        }
    }

    mutating func deleteFilter(with pattern: String, remainder: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {

        case .dictionary(let dict):
            let regex = try NSRegularExpression(with: pattern)

            let modified = try dict.compactMap { (key, value) -> (String, ValueType)? in
                guard regex.validate(key) else { return (key, value) }
                var value = value
                let shouldDelete = try value.delete(path: remainder, deleteIfEmpty: deleteIfEmpty)

                if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                    return nil
                } else {
                    return (key, value)
                }
            }

            self = .dictionary(Dictionary(uniqueKeysWithValues: modified))

        case .filter(var dict):
            try dict.modifyEachValue { try $0.deleteFilter(with: pattern, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .filter(dict)

        case .slice(var array):
            try array.modifyEach { try $0.deleteFilter(with: pattern, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            self = .slice(array)

        default:
            throw ValueTypeError.wrongUsage(of: .filter(pattern))
        }
    }
}
