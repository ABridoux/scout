import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat> {

    // MARK: - Properties

    var value: Any

    var isDictionary: Bool { value is [String: Any] }
    var isArray: Bool { value is [Any] }

    public var readingPath = Path()

    // MARK: - Initialization

    public init(data: Data) throws {
        let raw = try F.serialize(data: data)

        if let dict = raw as? [String: Any] {
            value = dict
        } else if let array = raw as? [Any] {
            value = array
        } else {
            throw PathExplorerError.invalidData(F.self)
        }
    }

    public init(value: Any) {
        self.value = value
    }

    init(value: Any, path: Path) {
        self.value = value
        readingPath = path
    }

    // MARK: - Functions

    // MARK: Get

    func get(for key: String) throws -> Self {
        guard let dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        return PathExplorerSerialization(value: childValue, path: readingPath.appending(key))
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = true) throws -> Self {
        guard let array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(readingPath)
        }

        if index == -1, negativeIndexEnabled {
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

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element pathElement: PathElement, negativeIndexEnabled: Bool = true) throws -> Self {
        switch pathElement {
        case .key(let key): return try get(for: key)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)
        }
    }

    public func get(_ path: Path) throws -> Self {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0.pathValue)
        }

        return currentPathExplorer
    }

    // MARK: Set

    mutating func set(key: String, to newValue: Any) throws {
        guard var dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard dict[key] != nil else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        dict[key] = newValue
        value = dict
    }

    mutating func set(index: Int, to newValue: Any) throws {
        guard var array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(readingPath)
        }

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

    mutating func set(element pathElement: PathElement, to newValue: Any) throws {
        switch pathElement {
        case .key(let key): return try set(key: key, to: newValue)
        case .index(let index): return try set(index: index, to: newValue)
        }
    }

    public mutating func set<Type: KeyAllowedType>(_ path: Path, to newValue: Any, as type: KeyType<Type>) throws {
        let newValue = try convert(newValue, to: type)

        var pathElements = path

        guard !pathElements.isEmpty else { return }

        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0.pathValue)
            pathExplorers.append(currentPathExplorer)
        }

        if let futureUpdatedValue = try? currentPathExplorer.get(lastElement.pathValue),
        futureUpdatedValue.isArray || futureUpdatedValue.isDictionary {
            throw PathExplorerError.wrongValueForKey(value: newValue, element: lastElement.pathValue)
        }

        try currentPathExplorer.set(element: lastElement.pathValue, to: newValue)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element.pathValue, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        self = currentPathExplorer
    }

    // -- Key name

    mutating func change(key: String, nameTo newKeyName: String) throws {
        guard var dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        dict[newKeyName] = childValue
        dict.removeValue(forKey: key)
        value = dict
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        var pathElements = path

        guard !pathElements.isEmpty else { return }

        guard let lastElement = pathElements.removeLast().pathValue.key else {
           throw PathExplorerError.underlyingError("Cannot modify key name in an array")
       }

        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0.pathValue)
            pathExplorers.append(currentPathExplorer)
        }

        try currentPathExplorer.change(key: lastElement, nameTo: newKeyName)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
           var pathExplorer = pathExplorer
        try pathExplorer.set(element: element.pathValue, to: currentPathExplorer.value)
           currentPathExplorer = pathExplorer
        }

        self = currentPathExplorer
       }

    // MARK: Delete

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key):
            guard var dict = value as? [String: Any] else {
                throw PathExplorerError.dictionarySubscript(readingPath)
            }

            guard dict[key] != nil else {
                throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
            }

            dict.removeValue(forKey: key)
            value = dict

        case .index(let index):
            guard var array = value as? [Any] else {
                throw PathExplorerError.arraySubscript(readingPath)
            }

            if index == -1 {
                guard !array.isEmpty else {
                    throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
                }
                array.removeLast()
                value = array
                return
            }

            guard 0 <= index, index < array.count else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }

            array.remove(at: index)
            value = array
        }
    }

    public mutating func delete(_ path: Path) throws {
        var pathElements = path

        guard !pathElements.isEmpty else { return }

        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0.pathValue)
            pathExplorers.append(currentPathExplorer)
        }

        try currentPathExplorer.delete(element: lastElement.pathValue)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element.pathValue, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        self = currentPathExplorer
    }

    // MARK: Add

    /// Add the new value to the array or dictionary value
    /// - Parameters:
    ///   - newValue: The new value to add
    ///   - element: If string, try to add the new value to the dictionary. If int, try to add the new value to the array. `-1` will add the value at the end of the array.
    /// - Throws: if self cannot be subscript with the given element
    mutating func add(_ newValue: Any, for element: PathElement) throws {

        if var dict = value as? [String: Any] {
            guard let key = element.key else {
                throw PathExplorerError.dictionarySubscript(readingPath)
            }
            dict[key] = newValue
            value = dict

        } else if var array = value as? [Any] {
            guard let index = element.index else {
                throw PathExplorerError.arraySubscript(readingPath)
            }

            if index == -1 || array.isEmpty {
                // add the new value at the end of the array
                array.append(newValue)
            } else if index >= 0, array.count >= index {
                // insert the new value at the index
                array.insert(newValue, at: index)
            } else {
                throw PathExplorerError.wrongValueForKey(value: value, element: index.pathValue)
            }
            value = array
        }
    }

    /// Create a new dictionary or array path explorer depending in the child key
    /// - Parameters:
    ///   - childKey: If string, the path explorer will be a dictionary. Array if int
    /// - Returns: The newly created path explorer
    func makeDictionaryOrArray(childKey: PathElement) -> Any {
        switch childKey {
        case .key: return [String: Any]() //dictionary
        case .index: return [Any]() //array
        }
    }

    public mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: type)

        var pathElements = path
        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        for (index, pathElement) in pathElements.enumerated() {
            // if the key already exists, retrieve it
            if let pathExplorer = try? currentPathExplorer.get(element: pathElement.pathValue, negativeIndexEnabled: false) {
                // when using the -1 index and adding a value,
                // we will consider it has to be added, not that it is used to target the last value
                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            } else {
                // add the new key
                let childValue = makeDictionaryOrArray(childKey: path[index + 1].pathValue)
                try currentPathExplorer.add(childValue, for: pathElement.pathValue)

                let pathExplorer = try currentPathExplorer.get(element: pathElement.pathValue)
                // remove the previously added path explorer as we added a new key to it
                pathExplorers.removeLast()
                pathExplorers.append(currentPathExplorer)

                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement.pathValue)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element.pathValue, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        value = currentPathExplorer.value
    }
}
