import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat> {

    // MARK: - Constants

    typealias DictionaryValue = [String: Any]
    typealias ArrayValue = [Any]

    // MARK: - Properties

    var value: Any

    var isDictionary: Bool { value is DictionaryValue }
    var isArray: Bool { value is ArrayValue }

    public var readingPath = Path()

    // MARK: - Initialization

    public init(data: Data) throws {
        let raw = try F.serialize(data: data)

        if let dict = raw as? DictionaryValue {
            value = dict
        } else if let array = raw as? ArrayValue {
            value = array
        } else {
            throw PathExplorerError.invalidData(serializationFormat: String(describing: F.self))
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
        guard let dict = value as? DictionaryValue else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        return PathExplorerSerialization(value: childValue, path: readingPath.appending(key))
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = true) throws -> Self {
        guard let array = value as? ArrayValue else {
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

    /// - Returns: The count of the array if  `value` is an array
    func getArrayCount() throws -> Self {
        guard let arrayValue = value as? ArrayValue else {
            throw PathExplorerError.arrayCountWrongUsage(path: readingPath)
        }

        return PathExplorerSerialization(value: arrayValue.count, path: readingPath.appending(.arrayCount))
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element pathElement: PathElement, negativeIndexEnabled: Bool = true) throws -> Self {
        switch pathElement {
        case .key(let key): return try get(for: key)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)
        case .arrayCount: return try getArrayCount()
        }
    }

    public func get(_ path: Path) throws -> Self {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        return currentPathExplorer
    }

    /// Explorer the path in parameter to find each `PathExplorer` in
    /// - Parameter path: The path to explore. Should not be empty
    /// - Throws: If the path is invalid, or contains an arrayCount `PathElement`
    /// - Returns: The explorers discovered
    func getExplorers(from path: Path) throws -> (explorers: [Self], path: Path, lastElement: PathElement) {
        assert(!path.isEmpty)

        var craftingPath = path
        let lastElement = craftingPath.removeLast()

        let explorers = try craftingPath.reduce([self]) { (explorers, element) in
            guard element != .arrayCount else { // arrayCount forbidden here
                throw PathExplorerError.arrayCountWrongUsage(path: path)
            }

            guard let currentExplorer = try explorers.last?.get(element: element) else {
                return explorers // should not happen
            }

            return explorers + [currentExplorer]
        }

        return (explorers, craftingPath, lastElement)
    }

    // MARK: Set

    mutating func set(key: String, to newValue: Any) throws {
        guard var dict = value as? DictionaryValue else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard dict[key] != nil else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        dict[key] = newValue
        value = dict
    }

    mutating func set(index: Int, to newValue: Any) throws {
        guard var array = value as? ArrayValue else {
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
        case .arrayCount: throw PathExplorerError.arrayCountWrongUsage(path: readingPath)
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

    // -- Key name

    mutating func change(key: String, nameTo newKeyName: String) throws {
        guard var dict = value as? DictionaryValue else {
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
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard let lastKey = lastElement.key else {
           throw PathExplorerError.underlyingError("Cannot modify key name in an array")
       }

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.change(key: lastKey, nameTo: newKeyName)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
           var pathExplorer = pathExplorer
        try pathExplorer.set(element: element, to: currentExplorer.value)
           currentExplorer = pathExplorer
        }

        self = currentExplorer
       }

    // MARK: Delete

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key):
            guard var dict = value as? DictionaryValue else {
                throw PathExplorerError.dictionarySubscript(readingPath)
            }

            guard dict[key] != nil else {
                throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
            }

            dict.removeValue(forKey: key)
            value = dict

        case .index(let index):
            guard var array = value as? ArrayValue else {
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

        case .arrayCount:
            throw PathExplorerError.arrayCountWrongUsage(path: readingPath)
        }
    }

    public mutating func delete(_ path: Path) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentExplorer.value)
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }

    // MARK: Add

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

            if index == -1 || array.isEmpty {
                // add the new value at the end of the array
                array.append(newValue)
            } else if index >= 0, array.count >= index {
                // insert the new value at the index
                array.insert(newValue, at: index)
            } else {
                throw PathExplorerError.wrongValueForKey(value: String(describing: value), element: .index(index))
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
        case .key: return DictionaryValue() //dictionary
        case .index: return ArrayValue() //array
        case .arrayCount: throw PathExplorerError.arrayCountWrongUsage(path: readingPath)
        }
    }

    public mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: type)

        var craftingPath = path
        let lastElement = craftingPath.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        for (index, element) in craftingPath.enumerated() {
            guard element != .arrayCount else {
                throw PathExplorerError.arrayCountWrongUsage(path: path)
            }

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
