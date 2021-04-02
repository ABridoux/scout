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
        guard let firstElement = path.first else { // empty path
            return true
        }

        let remainder = path.dropFirst()

        switch firstElement {
        case .key(let key): try delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty)
        case .index(let index): try delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty)
        default: fatalError()
        }

        return false
    }

    private mutating func delete(key: String, remainder: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {
        case .dictionary(var dict):

            try doAdd(key) {
                var value = try dict.getJaroWinkler(key: key)
                let shouldDelete = try value.delete(path: remainder, deleteIfEmpty: deleteIfEmpty)

                if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                    dict.removeValue(forKey: key)
                } else {
                    dict[key] = value
                }

                self = .dictionary(dict)
            }

        case .filter(var dict):
            try doAdd(key) {
                try dict.modifyEachValue { try $0.delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            }
            
            self = .filter(dict)

        case .slice(var array):
            try doAdd(key) {
                try array.modifyEach { try $0.delete(key: key, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            }

            self = .slice(array)

        default:
            throw ValueTypeError.subscriptKeyNoDict
        }
    }

    private mutating func delete(index: Int, remainder: SlicePath, deleteIfEmpty: Bool) throws {
        switch self {
        case .array(var array):

            try doAdd(index) {
                let index = try computeIndex(from: index, arrayCount: array.count)
                var value = array[index]
                let shouldDelete = try value.delete(path: remainder, deleteIfEmpty: deleteIfEmpty)

                if shouldDelete || (value.isEmpty && deleteIfEmpty) {
                    array.remove(at: index)
                } else {
                    array[index] = value
                }

                self = .array(array)
            }

        case .slice(var array):
            try doAdd(index) {
                try array.modifyEach { try $0.delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            }

            self = .slice(array)

        case .filter(var dict):
            try doAdd(index) {
                try dict.modifyEachValue { try $0.delete(index: index, remainder: remainder, deleteIfEmpty: deleteIfEmpty) }
            }

            self = .filter(dict)

        default:
            throw ValueTypeError.subscriptIndexNoArray
        }
    }
}
