//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    /// Add the new value to the array or dictionary value
    /// - Parameters:
    ///   - newValue: The new value to add
    ///   - element: If string, try to add the new value to the dictionary. If int, try to add the new value to the array. `-1` will add the value at the end of the array.
    /// - Throws: if self cannot be subscript with the given element
    mutating func add(_ newValue: Any, for element: PathElement) throws {

        if var dict = value as? DictionaryValue {
            guard let key = element.key else {
                throw PathExplorerError.dictionarySubscript(readingPath)
            }
            dict[key] = newValue
            value = dict

        } else if var array = value as? ArrayValue {
            guard let index = element.index else {
                throw PathExplorerError.arraySubscript(readingPath)
            }

            if index == .lastIndex || array.isEmpty {
                // add the new value at the end of the array
                array.append(newValue)
            } else if index >= 0, array.count >= index {
                // insert the new value at the index
                array.insert(newValue, at: index)
            } else {
                throw PathExplorerError.wrongValueForKey(value: String(describing: newValue), element: .index(index))
            }
            value = array
        }
    }

    /// Create a new dictionary or array path explorer depending in the child key
    /// - Parameters:
    ///   - childKey: If string, the path explorer will be a dictionary. Array if int
    /// - Returns: The newly created path explorer
    func makeDictionaryOrArray(childKey: PathElement) throws -> Any {
        switch childKey {
        case .key: return DictionaryValue()
        case .index: return ArrayValue()
        case .count, .slice: throw PathExplorerError.wrongUsage(of: childKey, in: readingPath)
        }
    }

    public mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: type)

        var craftingPath = path
        let lastElement = craftingPath.removeLast()

        try validateLast(element: lastElement, in: path)

        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        for (index, element) in craftingPath.enumerated() {
            // if the key already exists, retrieve it
            if let pathExplorer = try? currentPathExplorer.get(element: element, negativeIndexEnabled: false) {
                // when using the -1 index and adding a value,
                // we will consider it has to be added, not that it is used to target the last value
                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            } else {
                // add the new key
                let childValue = try makeDictionaryOrArray(childKey: path[index + 1])
                try currentPathExplorer.add(childValue, for: element)

                let pathExplorer = try currentPathExplorer.get(element: element)
                // remove the previously added path explorer as we added a new key to it
                pathExplorers.removeLast()
                pathExplorers.append(currentPathExplorer)

                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, craftingPath).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        value = currentPathExplorer.value
    }
}
