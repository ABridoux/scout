//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    mutating func set(key: String, to newValue: Any) throws {

        if isArray, isArraySlice {
            // array slice. We have to set all the values in the array
            var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.appending(key)))
            let newValues = try cast(newValue, as: .array, orThrow: .wrongArrayValueForKey(value: String(describing: newValue), element: .key(key)))

            guard array.count == newValues.count else {
                throw PathExplorerError.wrongArrayValueForKey(value: String(describing: newValue), element: .key(key))
            }

            for index in 0..<array.count {
                let oldDict = array[index]
                let newValue = newValues[index]
                let path = readingPath.appending(key)
                var pathExplorer = PathExplorerSerialization(value: oldDict, path: path)
                try pathExplorer.set(key: key, to: newValue)
                array[index] = pathExplorer.value
            }

            value = array
        } else {
            var dict = try getDictAndValueFor(key: key).dictionary
            dict[key] = newValue
            value = dict
        }
    }

    mutating func set(index: Int, to newValue: Any) throws {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if precedeKeyOrSliceAfterSlicing {
            // array slice. We have to set all the value in the array
            let newValues = try cast(newValue, as: .array, orThrow: .wrongArrayValueForKey(value: String(describing: newValue), element: .index(index)))

            guard array.count == newValues.count else {
                throw PathExplorerError.wrongArrayValueForKey(value: String(describing: newValue), element: .index(index))
            }

            for index in 0..<array.count {
                let oldArray = array[index]
                let newValue = newValues[index]
                let path = readingPath.appending(index)
                var pathExplorer = PathExplorerSerialization(value: oldArray, path: path)
                try pathExplorer.set(index: index, to: newValue)
                array[index] = pathExplorer.value
            }
            value = array

        } else {
            if index == .lastIndex {
                array.append(newValue)
                value = array
                return
            }

            guard array.count > index, index >= 0 else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }

            array[index] = newValue
            value = array
        }
    }

    mutating func setSlice(within bounds: Bounds, to newValue: Any) throws {
        let slice = PathElement.slice(bounds)
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))
        let range = try bounds.range(lastValidIndex: array.count - 1, path: readingPath.appending(slice))
        let newSlice = try cast(newValue, as: .array, orThrow: .wrongArrayValueForKey(value: String(describing: newValue), element: slice))
        array.replaceSubrange(range, with: newSlice)
        value = array
    }

    mutating func set(element: PathElement, to newValue: Any) throws {
        switch element {
        case .key(let key): return try set(key: key, to: newValue)
        case .index(let index): return try set(index: index, to: newValue)
        case .count: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try setSlice(within: bounds, to: newValue)
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
}
