//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    // MARK: - Array

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = true) throws -> Self {
        let newValue: Any

        switch lastGroupElement {

        case .arraySlice:
            let array = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            newValue = try get(index: index, inArraySlice: array)

        case .dictionaryFilter:
            let dict = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            newValue = try get(index: index, inDictionaryFilter: dict)

        case nil:
            newValue = try getSimple(index: index, negativeIndexEnabled: negativeIndexEnabled)
        }

        return PathExplorerSerialization(value: newValue, path: readingPath.appending(index))
    }

    func getSimple(index: Int, negativeIndexEnabled: Bool = true) throws -> Any {
        let array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if index == .lastIndex, negativeIndexEnabled {
            if array.isEmpty {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            return array[array.count - 1]
        } else {
            guard array.count > index, index >= 0 else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            return array[index]
        }
    }

    /// Get the given index in the array slice by browsing all the arrays in the slice
    func get(index: Int, inArraySlice array: ArrayValue) throws -> ArrayValue {
        var newArray = [Any]()

        for (elementIndex, element) in array.enumerated() {
            let path = readingPath.appending(.index(elementIndex))
            let pathExplorer = PathExplorerSerialization(value: element, path: path)
            let value = try pathExplorer.getSimple(index: index)
            newArray.append(value)
        }

        return newArray
    }

    /// Get the given index in the dictionary filter by browsing all the arrays in the slice
    func get(index: Int, inDictionaryFilter dictionary: DictionaryValue) throws -> DictionaryValue {
        var newDict = DictionaryValue()

        try dictionary.forEach { (key, value) in
            let pathExplorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))
            let newValue = try pathExplorer.getSimple(index: index)
            newDict[key + "[\(index)]"] = newValue
        }

        return newDict
    }

    // MARK: - Dictionary

    func get(for key: String) throws -> Self {
        let newValue: Any

        switch lastGroupElement {

        case .arraySlice:
            let array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.appending(key)))
            newValue = try get(key: key, inArraySlice: array)

        case .dictionaryFilter:
            let dict = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(readingPath))
            newValue = try get(key: key, inDictionaryFilter: dict)

        case nil:
            newValue = try getDictAndValueFor(key: key).value
        }

        return PathExplorerSerialization(value: newValue, path: readingPath.appending(key))
    }

    /// If `value` can be casted as a dictionary, and has the given key, return the dictionary and the key value in a tuple. Throws otherwise.
    func getDictAndValueFor(key: String) throws -> (dictionary: DictionaryValue, value: Any) {
        let dict = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(readingPath))

        guard let value = dict[key] else {
            let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(dict.keys))
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
        }

        return (dict, value)
    }

    /// Get the given key in the array slice by browsing all the dictionaries in the slice
    func get(key: String, inArraySlice array: ArrayValue) throws -> ArrayValue {
        var newArray = ArrayValue()

        for (index, element) in array.enumerated() {
            let path = readingPath.appending(.index(index))
            let pathExplorer = PathExplorerSerialization(value: element, path: path)
            let value = try pathExplorer.getDictAndValueFor(key: key).value
            newArray.append(value)
        }

        return newArray
    }

    /// Get the given key in the dictionary filter by browsing all the dictionaries in the filter
    func get(key: String, inDictionaryFilter dictionary: DictionaryValue) throws -> DictionaryValue {
        var newDict = DictionaryValue()

        try dictionary.forEach { (keyValue, value) in
            let pathExplorer = PathExplorerSerialization(value: value, path: readingPath.appending(keyValue))
            let value = try pathExplorer.getDictAndValueFor(key: key).value
            newDict[keyValue + "." + key] = value
        }

        return newDict
    }

    // MARK: - Count

    /// - Returns: The count of the array or dictionary if  `value` is an array or a dictionary
    func getChildrenCount() throws -> Self {
        #warning("Handle dictionaries filter")

        if precedeKeyOrSliceAfterSlicing {
            // Array slicing. Retrieve the count path element for all values in the arrays or dictionaries
            let array  = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))
            var countsArray = [Int]()

            for (index, value) in array.enumerated() {
                let pathExplorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                guard let count = try pathExplorer.getChildrenCount().int else {
                    throw PathExplorerError.wrongUsage(of: .count, in: readingPath.appending(index))
                }
                countsArray.append(count)
            }
            return PathExplorerSerialization(value: countsArray, path: readingPath.appending(.count))
        }

        if let arrayValue = value as? ArrayValue {
            return PathExplorerSerialization(value: arrayValue.count, path: readingPath.appending(.count))
        } else if let dictValue = value as? DictionaryValue {
            return PathExplorerSerialization(value: dictValue.count, path: readingPath.appending(.count))
        } else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }
    }

    // MARK: - Group

    /// Returns a slice of value is it is an array
    func getArraySlice(within bounds: Bounds) throws -> Self {
        #warning("Handle group elements")
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let array = try cast(value, as: .array, orThrow: .wrongUsage(of: slice, in: path))

        let sliceRange = try bounds.range(lastValidIndex: array.count - 1, path: path)

        let newValue = Array(array[sliceRange])
        return PathExplorerSerialization(value: newValue, path: path)
    }

    func getKeys(with pattern: String) throws -> Self {
        #warning("Handle group elements")
        let path = readingPath.appending(.filter(pattern))
        let regex = try NSRegularExpression(pattern: pattern, path: readingPath)

        if isArray {
            // allow the filter to be applied on string arrays
            let array = try cast(value, as: .array(.string), orThrow: .wrongUsage(of: .filter(pattern), in: path))
            let filteredArray = array.filter(regex.validate)
            return PathExplorerSerialization(value: filteredArray, path: path)
        }

        let dict = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(path))
        let filteredDict = dict.filter { regex.validate($0.key) }
        return PathExplorerSerialization(value: filteredDict, path: path)
    }

    // MARK: - General

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element: PathElement, negativeIndexEnabled: Bool = true) throws -> Self {
        guard readingPath.last != .count else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }

        switch element {
        case .key(let key): return try get(for: key)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)
        case .count: return try getChildrenCount()
        case .slice(let bounds): return try getArraySlice(within: bounds)
        case .filter(let pattern): return try getKeys(with: pattern)
        }
    }

    public func get(_ path: Path) throws -> Self {
        var currentPathExplorer = self

        try path.forEach { element in
            currentPathExplorer = try currentPathExplorer.get(element: element)
        }

        return currentPathExplorer
    }

    /// Explorer the path in parameter to find each `PathExplorer` in
    /// - Parameter path: The path to explore. Should not be empty
    /// - Throws: If the path is invalid
    /// - Returns: The explorers discovered, the path without the last element, and the last element
    func getExplorers(from path: Path) throws -> (explorers: [Self], path: Path, lastElement: PathElement) {
        assert(!path.isEmpty)

        var craftingPath = path
        let lastElement = craftingPath.removeLast()

        let explorers = try craftingPath.reduce([self]) { (explorers, element) in
            guard let currentExplorer = try explorers.last?.get(element: element) else {
                return explorers // should not happen
            }

            return explorers + [currentExplorer]
        }

        return (explorers, craftingPath, lastElement)
    }
}
