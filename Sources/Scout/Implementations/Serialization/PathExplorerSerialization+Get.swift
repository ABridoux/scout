//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    /// If `value` can be casted as a dictionary, and has the given key, return the dictionary and the key value in a tuple. Throws otherwise.
    func getDictAndValueFor(key: String) throws -> (dictionary: DictionaryValue, value: Any) {
        let dict = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(readingPath))

        guard let value = dict[key] else {
            let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(dict.keys))
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
        }

        return (dict, value)
    }

    func get(for key: String) throws -> Self {
        let newValue: Any

        if isArray, isArraySlice {
            // array slice. Try to find the common key in the array
            let array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.appending(key)))
            var newArray = [Any]()

            for (index, element) in array.enumerated() {
                let path = readingPath.appending(.index(index))
                let pathExplorer = PathExplorerSerialization(value: element, path: path)
                let value = try pathExplorer.getDictAndValueFor(key: key).value
                newArray.append(value)
            }

            newValue = newArray
        } else {
            newValue = try getDictAndValueFor(key: key).value
        }

        return PathExplorerSerialization(value: newValue, path: readingPath.appending(key))
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = true) throws -> Self {
        let array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if precedeKeyOrSliceAfterSlicing {
            // array slice. Try to find the common index in the array
            var newArray = [Any]()

            for (elementIndex, element) in array.enumerated() {
                let path = readingPath.appending(.index(elementIndex))
                let pathExplorer = PathExplorerSerialization(value: element, path: path)
                let value = try pathExplorer.get(at: index).value
                newArray.append(value)
            }

            return PathExplorerSerialization(value: newArray, path: readingPath.appending(index))
        }

        if index == .lastIndex, negativeIndexEnabled {
            if array.isEmpty {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            return PathExplorerSerialization(value: array[array.count - 1], path: readingPath.appending(index))
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        return PathExplorerSerialization(value: array[index], path: readingPath.appending(index))
    }

    /// - Returns: The count of the array or dictionary if  `value` is an array or a dictionary
    func getChildrenCount() throws -> Self {
        if let arrayValue = value as? ArrayValue {
            return PathExplorerSerialization(value: arrayValue.count, path: readingPath.appending(.count))
        } else if let dictValue = value as? DictionaryValue {
            return PathExplorerSerialization(value: dictValue.count, path: readingPath.appending(.count))
        } else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }
    }

    /// Returns a slice of value is it is an array
    func getArraySlice(within bounds: Bounds) throws -> Self {
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let array = try cast(value, as: .array, orThrow: .wrongUsage(of: slice, in: path))

        let sliceRange = try bounds.range(lastValidIndex: array.count - 1, path: path)

        let newValue = Array(array[sliceRange])
        return PathExplorerSerialization(value: newValue, path: path)
    }

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
