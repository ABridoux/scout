//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - Set

extension ExplorerValue {

    // MARK: PathExplorer

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try _set(path: Slice(path), to: newValue)
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self {
        var copy = self
        try copy.set(path, to: newValue)
        return copy
    }

    // MARK: General function

    private mutating func _set(path: SlicePath, to newValue: ExplorerValue) throws {
        guard let (head, tail) = path.headAndTail() else {
            self = newValue
            return
        }

        try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): try set(key: key, to: newValue, tail: tail)
            case .index(let index): try set(index: index, to: newValue, tail: tail)
            default: throw ExplorerError.wrongUsage(of: head)
            }
        }
    }

    // MARK: PathElement

    private mutating func set(key: String, to newValue: ExplorerValue, tail: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
        var value = try dict.getJaroWinkler(key: key)
        try value._set(path: tail, to: newValue)
        dict[key] = value
        self = .dictionary(dict)
    }

    private mutating func set(index: Int, to newValue: Self, tail: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        let index = try Self.computeIndex(from: index, arrayCount: array.count)
        var element = array[index]
        try element._set(path: tail, to: newValue)
        array[index] = element
        self = .array(array)
    }
}

// MARK: - Set key name

extension ExplorerValue {

    // MARK: PathExplorer

    public mutating func set(_ path: Path, keyNameTo keyName: String) throws {
        try _set(path: Slice(path), keyName: keyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> Self {
        var copy = self
        try copy._set(path: Slice(path), keyName: keyName)
        return copy
    }

    // MARK: General function

    private mutating func _set(path: SlicePath, keyName: String) throws {
        guard let firstElement = path.first else { return }
        let tail = path.dropFirst()

        if tail.isEmpty {
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
        case .key(let key): try set(key: key, keyName: keyName, tail: tail)
        case .index(let index): try set(index: index, keyName: keyName, tail: tail)
        default: throw ExplorerError.wrongUsage(of: firstElement)
        }
    }

    // MARK: PathElement

    private mutating func set(key: String, keyName: String, tail: SlicePath) throws {
        var dict = try dictionary.unwrapOrThrow(.subscriptKeyNoDict)
        var value = try dict.getJaroWinkler(key: key)
        try value._set(path: tail, keyName: keyName)
        dict[key] = value
        self = .dictionary(dict)
    }

    private mutating func set(index: Int, keyName: String, tail: SlicePath) throws {
        var array = try self.array.unwrapOrThrow(.subscriptIndexNoArray)
        let index = try Self.computeIndex(from: index, arrayCount: array.count)
        var element = array[index]
        try element._set(path: tail, keyName: keyName)
        array[index] = element
        self = .array(array)
    }
}
