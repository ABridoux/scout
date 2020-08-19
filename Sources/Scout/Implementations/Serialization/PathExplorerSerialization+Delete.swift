//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    // MARK: - Dictionary

    mutating func delete(key: String) throws {

        let groupDescription = lastGroupElement?.description ?? ""
        let valueDescription = String(describing: value)

        switch lastGroupElement {

        case .arraySlice:
            var array = try cast(value, as: .array,
                                 orThrow: .wrongGroupValueForKey(group: groupDescription, value: valueDescription, element: .key(key)))
            try delete(key: key, inArraySlice: &array)
            value = array

        case .dictionaryFilter:
            var dictionary = try cast(value, as: .dictionary,
                                      orThrow: .wrongGroupValueForKey(group: groupDescription, value: valueDescription, element: .key(key)))
            try delete(key: key, inDictionaryFilter: &dictionary)
            value = dictionary

        case nil:
            value = try deleteSimple(key: key)
        }
    }

    func deleteSimple(key: String) throws -> DictionaryValue {
        var dict = try getDictAndValueFor(key: key).dictionary
        dict.removeValue(forKey: key)
        return dict
    }

    func delete(key: String, inArraySlice array: inout ArrayValue) throws {
        for (index, oldValue) in array.enumerated() {
            let path = readingPath.appending(index)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            array[index] = try pathExplorer.deleteSimple(key: key)
        }
    }

    func delete(key: String, inDictionaryFilter dictionary: inout DictionaryValue) throws {
        try dictionary.forEach { (keyValue, oldValue) in
            let path = readingPath.appending(keyValue)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            dictionary[keyValue] = try pathExplorer.deleteSimple(key: key)
        }
    }

    // MARK: - Array

    mutating func delete(at index: Int) throws {

        switch lastGroupElement {
        case .arraySlice:
            var array = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try delete(index: index, inArarySlice: &array)
            value = array

        case .dictionaryFilter:
            var dictionary = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try delete(index: index, inDictionaryFilter: &dictionary)
            value = dictionary

        case nil:
            value = try deleteSimple(index: index)
        }
    }

    func deleteSimple(index: Int) throws -> ArrayValue {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if index == .lastIndex {
            if array.isEmpty {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            array.removeLast()
            return array
        }

        guard 0 <= index, index < array.count else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        array.remove(at: index)

        return array
    }

    func delete(index: Int, inArarySlice array: inout ArrayValue) throws {
        for (valueIndex, oldValue) in array.enumerated() {
            let path = readingPath.appending(valueIndex)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            array[valueIndex] = try pathExplorer.deleteSimple(index: index)
        }
    }

    func delete(index: Int, inDictionaryFilter dictionary: inout DictionaryValue) throws {
        try dictionary.forEach { (keyValue, oldValue) in
            let path = readingPath.appending(keyValue)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            dictionary[keyValue] = try pathExplorer.deleteSimple(index: index)
        }
    }

    // MARK: - Group

    mutating func deleteSlice(within bounds: Bounds) throws {
        #warning("Handles group")
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let array = try cast(value, as: .array, orThrow: .wrongUsage(of: .slice(bounds), in: path))

        let range = try bounds.range(lastValidIndex: array.count - 1, path: path)
        let newArray = array.remove(in: range)
        value = newArray
    }

    mutating func deleteKeys(with pattern: String) throws {
        #warning("To be implemented")
    }

    // MARK: - General

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key): try delete(key: key)
        case .index(let index): try delete(at: index)
        case .count: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try deleteSlice(within: bounds)
        case .filter(let pattern): try deleteKeys(with: pattern)
        }
    }

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool = false) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            if deleteIfEmpty, currentExplorer.isEmpty {
                try pathExplorer.delete(element: element)
            } else {
                try pathExplorer.set(element: element, to: currentExplorer.value)
            }
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }
}
