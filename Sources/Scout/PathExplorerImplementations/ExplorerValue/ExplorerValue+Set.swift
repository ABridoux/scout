//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

// MARK: - Set

extension ExplorerValue {

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try _set(path: Slice(path), to: newValue)
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self {
        var copy = self
        try copy.set(path, to: newValue)
        return copy
    }

    private mutating func _set(path: SlicePath, to newValue: ExplorerValue) throws {
        guard let firstElement = path.first else {
            return self = newValue
        }

        let remainder = path.dropFirst()

        try doSettingPath(remainder.leftPart) {
            switch firstElement {
            case .key(let key): try set(key: key, to: newValue, remainder: remainder)
            case .index(let index): try set(index: index, to: newValue, remainder: remainder)
            default: throw ExplorerError.wrongUsage(of: firstElement)
            }
        }
    }

    // MARK: Key

    private mutating func set(key: String, to newValue: ExplorerValue, remainder: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
        var value = try dict.getJaroWinkler(key: key)
        try value._set(path: remainder, to: newValue)
        dict[key] = value
        self = .dictionary(dict)
    }

    // MARK: Index

    private mutating func set(index: Int, to newValue: Self, remainder: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        let index = try computeIndex(from: index, arrayCount: array.count)
        var element = array[index]
        try element._set(path: remainder, to: newValue)
        array[index] = element
        self = .array(array)
    }
}

// MARK: - Set key name

extension ExplorerValue {

    public mutating func set(_ path: Path, keyNameTo keyName: String) throws {
        try set(path: Slice(path), keyName: keyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> Self {
        var copy = self
        try copy.set(path: Slice(path), keyName: keyName)
        return copy
    }

    private mutating func set(path: SlicePath, keyName: String) throws {
        guard let firstElement = path.first else { return }
        let remainder = path.dropFirst()

        if remainder.isEmpty {
            guard let key = firstElement.key else {
                throw ExplorerError.wrongUsage(of: firstElement)
            }

            var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
            let value = try dict.getJaroWinkler(key: key)
            dict.removeValue(forKey: key)
            dict[keyName] = value
            self = .dictionary(dict)
            return
        }

        switch firstElement {
        case .key(let key): try set(key: key, keyName: keyName, remainder: remainder)
        case .index(let index): try set(index: index, keyName: keyName, remainder: remainder)
        default: throw ExplorerError.wrongUsage(of: firstElement)
        }
    }

    // MARK: Key

    private mutating func set(key: String, keyName: String, remainder: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)

        var value = try dict.getJaroWinkler(key: key)
        try value.set(path: remainder, keyName: keyName)
        dict[key] = value
        self = .dictionary(dict)
    }

    // MARK: Index

    private mutating func set(index: Int, keyName: String, remainder: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)

        let index = try computeIndex(from: index, arrayCount: array.count)
        var element = array[index]
        try element.set(path: remainder, keyName: keyName)
        array[index] = element
        self = .array(array)
    }
}
