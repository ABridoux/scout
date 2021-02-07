//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    // MARK: - Array

    mutating func set(at index: Int, to newValue: Any) throws {

        switch lastGroupSample {
        case .arraySlice:
            var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .array, orThrow: .groupSampleConversionError(readingPath))

            try set(at: index, inArraySlice: &arraySlice, to: newValues)
            value = arraySlice

        case .dictionaryFilter:
            var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))

            try set(at: index, inDictionaryFilter: &dictionaryFilter, to: newValues)
            value = dictionaryFilter

        case nil:
            value = try setSingle(at: index, to: newValue)
        }
    }

    /// Set the index in the given array to the new value
    func setSingle(at index: Int, to newValue: Any) throws -> ArrayValue {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.flattened()))
        let computedIndex = index < 0 ? array.count + index : index

        if array.isEmpty, index == -1 { // add the value if targeting the last possible index when empty
            array.append(newValue)
            return array
        }

        guard 0 <= computedIndex, computedIndex < array.count else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        if !allowEmptyGroups, isValueEmpty(newValue) {
            array.remove(at: computedIndex)
        } else {
            array[computedIndex] = newValue
        }

        return array
    }

    /// Set the given index in the array slice by browsing all the arrays in the slice
    func set(at index: Int, inArraySlice array: inout ArrayValue, to newValues: ArrayValue) throws {
        guard array.count == newValues.count else {
            throw PathExplorerError.wrongGroupValueForKey(group: GroupSample.arraySliceEmpty.name,
                                                          value: String(describing: newValues),
                                                          element: .index(index))
        }

        for indexElement in 0..<array.count {
            let oldArray = array[indexElement]
            let newValue = newValues[indexElement]
            let path = readingPath.appending(indexElement)
            var pathExplorer = PathExplorerSerialization(value: oldArray, path: path)
            pathExplorer.allowEmptyGroups = allowEmptyGroups
            array[index] = try pathExplorer.setSingle(at: index, to: newValue)
        }
    }

    /// Set the given index in the dictionray filter by browsing all the arrays in the filter
    func set(at index: Int, inDictionaryFilter dictionary: inout DictionaryValue, to newValues: DictionaryValue) throws {
        for (subKey, newValue) in newValues {
            guard let oldValue = dictionary[subKey] else { continue } // ignore non already present keys
            let path = readingPath.appending(index)
            var pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            pathExplorer.allowEmptyGroups = allowEmptyGroups
            dictionary[subKey] = try pathExplorer.setSingle(at: index, to: newValue)
        }
    }

    // MARK: - Dictionary

    /// Set the key in the given dictionary to the new value
    mutating func set(for key: String, to newValue: Any) throws {
        switch lastGroupSample {

        case .arraySlice:
            var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try set(for: key, inArraySlice: &arraySlice, to: newValues)
            value = arraySlice

        case .dictionaryFilter:
            var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            let newValues = try cast(newValue, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try set(for: key, inDictionaryFilter: &dictionaryFilter, to: newValues)
            value = dictionaryFilter

        case nil:
            value = try setSingle(for: key, to: newValue)
        }
    }

    func setSingle(for key: String, to newValue: Any) throws -> DictionaryValue {
        var dict = try getDictAndValueFor(for: key).dictionary

        if !allowEmptyGroups, isValueEmpty(newValue ) {
            dict.removeValue(forKey: key)
            return dict
        }

        dict[key] = newValue
        return dict
    }

    /// Set the given key in the array slice by browsing all the arrays in the slice
    func set(for key: String, inArraySlice array: inout ArrayValue, to newValues: ArrayValue) throws {
        guard array.count == newValues.count else {
            throw PathExplorerError.wrongGroupValueForKey(group: GroupSample.arraySliceEmpty.name,
                                                          value: String(describing: newValues),
                                                          element: .key(key))
        }

        for index in 0..<array.count {
            let oldValue = array[index]
            let newValue = newValues[index]
            let path = readingPath.appending(index)
            var pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            pathExplorer.allowEmptyGroups = allowEmptyGroups
            array[index] = try pathExplorer.setSingle(for: key, to: newValue)
        }
    }

    /// Set the given key in the dictionary filter by browsing all the arrays in the filter
    func set(for key: String, inDictionaryFilter dictionary: inout DictionaryValue, to newValues: DictionaryValue) throws {
        for (subKey, newValue) in newValues {
            guard let oldValue = dictionary[subKey] else { continue } // ignore non already present keys
            let path = readingPath.appending(subKey)
            var pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            pathExplorer.allowEmptyGroups = allowEmptyGroups
            dictionary[subKey] = try pathExplorer.setSingle(for: key, to: newValue)
        }
    }

    // MARK: - Group

    mutating func setArraySlice(within bounds: Bounds, to newValue: Any) throws {
        let slice = PathElement.slice(bounds)
        let array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.flattened()))
        let newSlice = try cast(newValue, as: .array,
                                orThrow: .wrongGroupValueForKey(group: GroupSample.arraySliceEmpty.name, value: String(describing: newValue), element: slice))

        let range = try bounds.range(arrayCount: array.count, path: readingPath)
        let leftRange = range.lowerBound > 0 ? 0...range.lowerBound - 1 : nil
        let rightRange = range.upperBound < array.count - 1 ? range.upperBound + 1...array.count - 1 : nil

        var newArraySlice = ArrayValue()

        if let range = leftRange {
            // array[range] does not play good with any
            range.forEach { newArraySlice.append(array[$0]) }
        }

        newSlice.forEach { value in
            if allowEmptyGroups || !isValueEmpty(value) { // if empty groups are forbidden, avoid to add them
                newArraySlice.append(value)
            }
        }

        if let range = rightRange {
            // array[range] does not play good with any
            range.forEach { newArraySlice.append(array[$0]) }
        }

        value = newArraySlice
    }

    mutating func setDictionaryFilter(with pattern: String, to newValue: Any) throws {
        let filter = PathElement.filter(pattern)
        var newDictFilter = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(readingPath))

        let newDict = try cast(newValue, as: .dictionary,
                                orThrow: .wrongGroupValueForKey(group: GroupSample.arraySliceEmpty.name, value: String(describing: newValue), element: filter))

        newDict.forEach { (key, value) in
            if !allowEmptyGroups, PathExplorerSerialization(value: value).isEmpty {
                newDictFilter.removeValue(forKey: key)
            } else {
                newDictFilter[key] = value
            }
        }
        value = newDictFilter
    }

    // MARK: - Key name

    mutating func change(key: String, nameTo newKeyName: String) throws {
        var (dict, value) = try getDictAndValueFor(for: key)

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
        case .key(let key): return try set(for: key, to: newValue)
        case .index(let index): return try set(at: index, to: newValue)
        case .count, .keysList: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try setArraySlice(within: bounds, to: newValue)
        case .filter(let pattern): try setDictionaryFilter(with: pattern, to: newValue)
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
