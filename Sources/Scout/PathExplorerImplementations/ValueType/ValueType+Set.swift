//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Set

extension ValueType {

    public mutating func set(_ path: Path, to newValue: Any) throws {
        try set(path: Slice(path), to: Self(value: newValue))
    }

    public mutating func set(_ path: PathElement..., to newValue: Any) throws {
        try set(path: Path(path)[...], to: Self(value: newValue))
    }

    private mutating func set(path: SlicePath, to newValue: Self) throws {
        guard let firstElement = path.first else {
            return self = newValue
        }

        let remainder = path.dropFirst()

        switch firstElement {
        case .key(let key): try set(key: key, to: newValue, remainder: remainder)
        case .index(let index): try set(index: index, to: newValue, remainder: remainder)
        default: throw ValueTypeError.wrongUsage(of: firstElement)
        }
    }

    // MARK: Key

    private mutating func set(key: String, to newValue: ValueType, remainder: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)

        try doAdd(key) {
            var value = try dict.getJaroWinkler(key: key)
            try value.set(path: remainder, to: newValue)
            dict[key] = value
            self = .dictionary(dict)
        }
    }

    // MARK: Index

    private mutating func set(index: Int, to newValue: Self, remainder: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)

        try doAdd(index) {
            let index = try computeIndex(from: index, arrayCount: array.count)
            var element = array[index]
            try element.set(path: remainder, to: newValue)
            array[index] = element
            self = .array(array)
        }
    }
}

// MARK: - Set key name

extension ValueType {

    public mutating func set(_ path: Path, keyNameTo keyName: String) throws {
        try set(path: Slice(path), keyName: keyName)
    }

    public mutating func set(_ path: PathElement, keyNameTo keyName: String) throws {
        try set(path: Path(path)[...], keyName: keyName)
    }

    private mutating func set(path: SlicePath, keyName: String) throws {
        guard let firstElement = path.first else {
            assertionFailure("This case should not be possible")
            return
        }

        let remainder = path.dropFirst()

        if remainder.isEmpty {
            guard let key = firstElement.key else {
                throw ValueTypeError.wrongUsage(of: firstElement)
            }

            var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
            try doAdd(key) {
                let value = try dict.getJaroWinkler(key: key)
                dict.removeValue(forKey: key)
                dict[keyName] = value
                self = .dictionary(dict)
            }
            return
        }

        switch firstElement {
        case .key(let key): try set(key: key, keyName: keyName, remainder: remainder)
        case .index(let index): try set(index: index, keyName: keyName, remainder: remainder)
        default: throw ValueTypeError.wrongUsage(of: firstElement)
        }
    }

    // MARK: Key

    private mutating func set(key: String, keyName: String, remainder: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)

        try doAdd(key) {
            var value = try dict.getJaroWinkler(key: key)
            try value.set(path: remainder, keyName: keyName)
            dict[key] = value
            self = .dictionary(dict)
        }
    }

    // MARK: Index

    private mutating func set(index: Int, keyName: String, remainder: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)

        try doAdd(index) {
            let index = try computeIndex(from: index, arrayCount: array.count)
            var element = array[index]
            try element.set(path: remainder, keyName: keyName)
            array[index] = element
            self = .array(array)
        }
    }
}