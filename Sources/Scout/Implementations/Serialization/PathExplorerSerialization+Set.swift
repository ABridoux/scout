//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    // MARK: - Array

    mutating func set(index: Int, to newValue: Any) throws {

        switch lastGroupElement {
        case .arraySlice:
            var array = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .array, orThrow: .groupSampleConversionError(readingPath))

            try set(index: index, inArraySlice: &array, to: newValues)
            value = array

        case .dictionaryFilter:
            var dict = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))

            try set(index: index, inDictionaryFilter: &dict, to: newValues)
            value = dict

        case nil:
            value = try setSimple(index: index, to: newValue)
        }
    }

    /// Set the index in the given array to the new value
    func setSimple(index: Int, to newValue: Any) throws -> ArrayValue {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if index == .lastIndex {
            array.append(newValue)
            return array
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        array[index] = newValue
        return array
    }

    /// Set the given index in the array slice by browsing all the arrays in the slice
    func set(index: Int, inArraySlice array: inout ArrayValue, to newValues: ArrayValue) throws {
        guard array.count == newValues.count else {
            throw PathExplorerError.wrongGroupValueForKey(group: GroupSample.arraySlice.description,
                                                          value: String(describing: newValues),
                                                          element: .index(index))
        }

        for indexElement in 0..<array.count {
            let oldArray = array[indexElement]
            let newValue = newValues[indexElement]
            let path = readingPath.appending(indexElement)
            let pathExplorer = PathExplorerSerialization(value: oldArray, path: path)
            array[index] = try pathExplorer.setSimple(index: index, to: newValue)
        }
    }

    /// Set the given index in the dictionray filter by browsing all the arrays in the filter
    func set(index: Int, inDictionaryFilter dictionary: inout DictionaryValue, to newValues: DictionaryValue) throws {
        for (subKey, newValue) in newValues {
            guard let oldValue = dictionary[subKey] else { continue } // ignore non already present keys
            let path = readingPath.appending(index)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            dictionary[subKey] = try pathExplorer.setSimple(index: index, to: newValue)
        }
    }

    // MARK: - Dictionary

    /// Set the key in the given dictionary to the new value
    mutating func set(key: String, to newValue: Any) throws {

        switch lastGroupElement {

        case .arraySlice:
            var array = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try set(key: key, inArraySlice: &array, to: newValues)
            value = array

        case .dictionaryFilter:
            var dict = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try set(key: key, inDictionaryFilter: &dict, to: newValues)
            value = dict

        case nil:
            value = try setSimple(key: key, to: newValue)
        }
    }

    func setSimple(key: String, to newValue: Any) throws -> DictionaryValue {
        var dict = try getDictAndValueFor(key: key).dictionary
        dict[key] = newValue
        return dict
    }

    /// Set the given key in the array slice by browsing all the arrays in the slice
    func set(key: String, inArraySlice array: inout ArrayValue, to newValues: ArrayValue) throws {
        guard array.count == newValues.count else {
            throw PathExplorerError.wrongGroupValueForKey(group: GroupSample.arraySlice.description,
                                                          value: String(describing: newValues),
                                                          element: .key(key))
        }

        for index in 0..<array.count {
            let oldValue = array[index]
            let newValue = newValues[index]
            let path = readingPath.appending(index)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            array[index] = try pathExplorer.setSimple(key: key, to: newValue)
        }
    }

    /// Set the given key in the dictionary filter by browsing all the arrays in the filter
    func set(key: String, inDictionaryFilter dictionary: inout DictionaryValue, to newValues: DictionaryValue) throws {
        for (subKey, newValue) in newValues {
            guard let oldValue = dictionary[subKey] else { continue } // ignore non already present keys
            var oldDict = try cast(oldValue, as: .dictionary, orThrow: .wrongGroupValueForKey(group: GroupSample.dictionaryFilter.description, value: String(describing: oldValue), element: .key(key)))

            oldDict[key] = newValue
            dictionary[subKey] = oldDict
        }
    }

    // MARK: - Group

    mutating func setSlice(within bounds: Bounds, to newValue: Any) throws {
        #warning("Handle groups")
        let slice = PathElement.slice(bounds)
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))
        let range = try bounds.range(lastValidIndex: array.count - 1, path: readingPath.appending(slice))
        let newSlice = try cast(newValue, as: .array, orThrow: .wrongGroupValueForKey(group: GroupSample.arraySlice.description, value: String(describing: newValue), element: slice))
        array.replaceSubrange(range, with: newSlice)
        value = array
    }

    mutating func setKeys(with pattern: String, to newValue: Any) throws {
        #warning("To be implemented")
    }

    // MARK: - Key name

    mutating func change(key: String, nameTo newKeyName: String) throws {
        var (dict, value) = try getDictAndValueFor(key: key)

        dict[newKeyName] = value
        dict.removeValue(forKey: key)
        self.value = dict
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard case let .key(lastKey) = lastElement else {
            throw PathExplorerError.keyNameSetOnNonDictionary(path: path.appending(lastElement))
       }

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.appending(lastElement).description)' to set it")
        }

        try currentExplorer.change(key: lastKey, nameTo: newKeyName)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
           var pathExplorer = pathExplorer
        try pathExplorer.set(element: element, to: currentExplorer.value)
           currentExplorer = pathExplorer
        }

        self = currentExplorer
    }

    // MARK: - General

    mutating func set(element: PathElement, to newValue: Any) throws {
        switch element {
        case .key(let key): return try set(key: key, to: newValue)
        case .index(let index): return try set(index: index, to: newValue)
        case .count: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try setSlice(within: bounds, to: newValue)
        case .filter(let pattern): try setKeys(with: pattern, to: newValue)
        }
    }

    public mutating func set<Type: KeyAllowedType>(_ path: Path, to newValue: Any, as type: KeyType<Type>) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: type)

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        if let futureUpdatedValue = try? currentExplorer.get(lastElement),
        futureUpdatedValue.isArray || futureUpdatedValue.isDictionary {
            throw PathExplorerError.wrongValueForKey(value: String(describing: newValue), element: lastElement)
        }

        try currentExplorer.set(element: lastElement, to: newValue)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentExplorer.value)
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }
}
