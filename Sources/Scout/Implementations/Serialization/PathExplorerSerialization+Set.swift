//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    mutating func set(key: String, to newValue: Any) throws {
        var dict = try getDictAndValueFor(key: key).dictionary

        dict[key] = newValue
        value = dict
    }

    mutating func set(index: Int, to newValue: Any) throws {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if index == -1 {
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

    mutating func set(element: PathElement, to newValue: Any) throws {

        switch element {
        case .key(let key): return try set(key: key, to: newValue)
        case .index(let index): return try set(index: index, to: newValue)
        case .count: throw PathExplorerError.countWrongUsage(path: readingPath.appending(element))
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
