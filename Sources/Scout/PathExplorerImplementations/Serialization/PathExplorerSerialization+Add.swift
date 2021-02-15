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
                throw PathExplorerError.wrongElementToSubscript(group: Self.dictionaryTypeDescription, element: element, path: readingPath)
            }
            dict[key] = newValue
            value = dict

        } else if var array = value as? ArrayValue {
            switch element {

            case .count:
                // add the new value at the end of the array
                array.append(newValue)

            case .index(let index):
                let computedIndex = index < 0 ? array.count + index : index

                if (array.isEmpty && computedIndex == 0) || computedIndex == array.count {
                    // empty array so the value should be added anyway or adding a new value
                    array.append(newValue)
                } else if 0 <= computedIndex, computedIndex < array.count {
                    // insert the new value at the index
                    array.insert(newValue, at: computedIndex)
                } else {
                    throw PathExplorerError.subscriptWrongIndex(path: readingPath.flattened(), index: index, arrayCount: array.count)
                }

            default:
                throw PathExplorerError.wrongElementToSubscript(group: Self.arrayTypeDescription, element: element, path: readingPath)

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
        case .index, .count: return ArrayValue()
        case .keysList, .slice, .filter: throw PathExplorerError.wrongUsage(of: childKey, in: readingPath)
        }
    }

    public mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws {
        guard let lastElement = path.last else { return }

        let newValue = try convert(newValue, to: type)

        let parsingStorage = try addOrGetKeys(in: path)
        var currentPathExplorer = parsingStorage.currentExplorer
        try currentPathExplorer.add(newValue, for: lastElement)

        try zip(parsingStorage.foundPathExplorers, parsingStorage.craftingPath)
            .reversed()
            .forEach { pathExplorer, element in
                var pathExplorer = pathExplorer
                try pathExplorer.set(element: element, to: currentPathExplorer.value)
                currentPathExplorer = pathExplorer
        }

        value = currentPathExplorer.value
        readingPath = currentPathExplorer.readingPath
    }

    /// Parse the path, adding a key if it does not exist in the dictionay or array
    private func addOrGetKeys(in path: Path) throws -> PathParsingStorage {
        var currentPathExplorer = self
        var craftingPath = path[0..<path.count - 1]
        var pathExplorers = [currentPathExplorer]

        for (index, element) in craftingPath.enumerated() {
            var element = element

            if case .count = element {
                // count element: Append the value and replace the element with the new last index
                let array = try cast(currentPathExplorer.value, as: .array, orThrow: .wrongUsage(of: element, in: currentPathExplorer.readingPath))
                element = .index(array.count)
                craftingPath[index] = element
            }

            // if the key already exists, retrieve it
            if let pathExplorer = try? currentPathExplorer.get(element: element, negativeIndexEnabled: true, detailedName: true) {
                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            } else {
                // add the new key
                let childValue = try makeDictionaryOrArray(childKey: path[index + 1])
                try currentPathExplorer.add(childValue, for: element)

                let pathExplorer = try currentPathExplorer.get(element: element, detailedName: true)
                // remove the previously added path explorer as we added a new key to it
                pathExplorers.removeLast()
                pathExplorers.append(currentPathExplorer)
                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            }
        }

        return PathParsingStorage(currentExplorer: currentPathExplorer, craftingPath: Path(craftingPath), foundPathExplorers: pathExplorers)
    }
}

private extension PathExplorerSerialization {

    struct PathParsingStorage {
        var currentExplorer: PathExplorerSerialization
        var craftingPath: Path
        var foundPathExplorers: [PathExplorerSerialization]
    }
}
