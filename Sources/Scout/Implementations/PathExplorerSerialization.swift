import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat> {

    // MARK: - Properties

    var value: Any

    var isDictionary: Bool { value is [String: Any] }
    var isArray: Bool { value is [Any] }

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

    // MARK: - Functions

    // MARK: Get

    func get(for key: String) throws -> Self {
        guard let dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(value)
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(key)
        }

        return PathExplorerSerialization(value: childValue)
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = true) throws -> Self {
        guard let array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(value)
        }

        if index == -1, negativeIndexEnabled {
            if array.isEmpty {
                throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
            }
            return PathExplorerSerialization(value: array[array.count - 1])
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
        }

        return PathExplorerSerialization(value: array[index])
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element pathElement: PathElement, negativeIndexEnabled: Bool = true) throws -> Self {
        if let stringElement = pathElement as? String {
            return try get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return try get(at: intElement, negativeIndexEnabled: negativeIndexEnabled)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
    }

    public func get(_ path: Path) throws -> Self {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        return currentPathExplorer
    }

    // MARK: Set

    mutating func set(key: String, to newValue: Any) throws {
        guard var dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(value)
        }

        guard dict[key] != nil else {
            throw PathExplorerError.subscriptMissingKey(key)
        }

        dict[key] = newValue
        value = dict
    }

    mutating func set(index: Int, to newValue: Any) throws {
        guard var array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(value)
        }

        if index == -1 {
            array.append(newValue)
            value = array
            return
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
        }

        array[index] = newValue
        value = array
    }

    mutating func set(element pathElement: PathElement, to newValue: Any) throws {
        if let key = pathElement as? String {
            try set(key: key, to: newValue)
        } else if let index = pathElement as? Int {
            try set(index: index, to: newValue)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return
        }
    }

    public mutating func set<Type: KeyAllowedType>(_ path: [PathElement], to newValue: Any, as type: KeyType<Type>) throws {
        let newValue = try convert(newValue, to: type)

        var pathElements = path

        guard !pathElements.isEmpty else { return }

        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
            pathExplorers.append(currentPathExplorer)
        }

        if let futureUpdatedValue = try? currentPathExplorer.get(lastElement),
        futureUpdatedValue.isArray || futureUpdatedValue.isDictionary {
            throw PathExplorerError.wrongValueForKey(value: newValue, element: lastElement)
        }

        try currentPathExplorer.set(element: lastElement, to: newValue)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        self = currentPathExplorer
    }

    // -- Key name

    mutating func change(key: String, nameTo newKeyName: String) throws {
        guard var dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(String(describing: value))
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(key)
        }

        dict[newKeyName] = childValue
        dict.removeValue(forKey: key)
        value = dict
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
           var pathElements = path

           guard !pathElements.isEmpty else { return }

           guard let lastElement = pathElements.removeLast() as? String else {
               throw PathExplorerError.underlyingError("Cannot modify key name in an array")
           }

           var currentPathExplorer = self
           var pathExplorers = [currentPathExplorer]

           try pathElements.forEach {
               currentPathExplorer = try currentPathExplorer.get(element: $0)
               pathExplorers.append(currentPathExplorer)
           }

           try currentPathExplorer.change(key: lastElement, nameTo: newKeyName)

           for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
               var pathExplorer = pathExplorer
               try pathExplorer.set(element: element, to: currentPathExplorer.value)
               currentPathExplorer = pathExplorer
           }

           self = currentPathExplorer
       }

    // MARK: Delete

    mutating func delete(element: PathElement) throws {
        if let key = element as? String {
            guard var dict = value as? [String: Any] else {
                throw PathExplorerError.dictionarySubscript(value)
            }

            guard dict[key] != nil else {
                throw PathExplorerError.subscriptMissingKey(key)
            }

            dict.removeValue(forKey: key)
            value = dict

        } else if let index = element as? Int {
            guard var array = value as? [Any] else {
                throw PathExplorerError.arraySubscript(value)
            }

            if index == -1 {
                guard !array.isEmpty else {
                    throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
                }
                array.removeLast()
                value = array
                return
            }

            guard 0 <= index, index < array.count else {
                throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
            }

            array.remove(at: index)
            value = array
        } else {
            throw PathExplorerError.wrongValueForKey(value: value, element: element)
        }
    }

    public mutating func delete(_ path: Path) throws {
        var pathElements = path

        guard !pathElements.isEmpty else { return }

        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
            pathExplorers.append(currentPathExplorer)
        }

        try currentPathExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentPathExplorer.value)
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
            guard let key = element as? String else {
                throw PathExplorerError.dictionarySubscript(value)
            }
            dict[key] = newValue
            value = dict

        } else if var array = value as? [Any] {
            guard let index = element as? Int else {
                throw PathExplorerError.arraySubscript(value)
            }

            if index == -1 || array.isEmpty {
                // add the new value at the end of the array
                array.append(newValue)
            } else if index >= 0, array.count >= index {
                // insert the new value at the index
                array.insert(newValue, at: index)
            } else {
                throw PathExplorerError.wrongValueForKey(value: value, element: index)
            }
            value = array
        }
    }

    /// Create a new dictionary or array path explorer depending in the child key
    /// - Parameters:
    ///   - childKey: If string, the path explorer will be a dictionary. Array if int
    /// - Returns: The newly created path explorer
    func makeDictionaryOrArray(childKey: PathElement) -> Any {
        if childKey is String { // ditionary
            return [String: Any]()
        } else if childKey is Int { // array
            return [Any]()
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return ""
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
            if let pathExplorer = try? currentPathExplorer.get(element: pathElement, negativeIndexEnabled: false) {
                // when using the -1 index and adding a value,
                // we will consider it has to be added, not that it is used to target the last value
                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            } else {
                // add the new key
                let childValue = makeDictionaryOrArray(childKey: path[index + 1])
                try currentPathExplorer.add(childValue, for: pathElement)

                let pathExplorer = try currentPathExplorer.get(element: pathElement)
                // remove the previously added path explorer as we added a new key to it
                pathExplorers.removeLast()
                pathExplorers.append(currentPathExplorer)

                pathExplorers.append(pathExplorer)
                currentPathExplorer = pathExplorer
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, pathElements).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentPathExplorer.value)
            currentPathExplorer = pathExplorer
        }

        value = currentPathExplorer.value
    }
}

extension PathExplorerSerialization: PathExplorer {

    public var string: String? { value as? String }
    public var bool: Bool? { value as? Bool }
    public var int: Int? { value as? Int }
    public var real: Double? { value as? Double }

    public var stringValue: String {
        switch value {
        case let bool as Bool:
            return bool.description
        case let int as Int:
            return String(int)
        case let double as Double:
            return String(double)
        case let string as String:
            return string
        default:
                return ""
        }
    }

    public var description: String {
        if let description = try? exportString() {
            return description
        } else {
            return "Unable to convert \(String(describing: self)) to a String. The serialization has thrown an error. Try the `exportString()` function"
        }
    }

    public var format: DataFormat {
        if F.self == JsonFormat.self {
            return .json
        } else if F.self == PlistFormat.self {
            return .plist
        } else {
            fatalError("Serialiation format not recognized. Allowed: Jsonformat and PlistFormat")
        }

    }

    // MARK: Get

    public func get(_ pathElements: PathElement...) throws -> Self {
        try get(pathElements)
    }

    // MARK: Set

    public mutating func set(_ path: [PathElement], to newValue: Any) throws {
        try set(path, to: newValue, as: .automatic)
    }

    public mutating func set<Type: KeyAllowedType>(_ pathElements: PathElement..., to newValue: Any, as type: KeyType<Type>) throws {
        try set(pathElements, to: newValue, as: type)
    }

    public mutating func set(_ pathElements: PathElement..., to newValue: Any) throws {
        try set(pathElements, to: newValue, as: .automatic)
    }

    // -- Set key name

    public mutating func set(_ pathElements: PathElement..., keyNameTo newKeyName: String) throws {
        try set(pathElements, keyNameTo: newKeyName)
    }

    // MARK: Delete

    public mutating func delete(_ pathElements: PathElement...) throws {
        try delete(pathElements)
    }

    // MARK: Add

    public mutating func add(_ newValue: Any, at path: Path) throws {
        try add(newValue, at: path, as: .automatic)
    }

    public mutating func add(_ newValue: Any, at pathElements: PathElement...) throws {
        try add(newValue, at: pathElements, as: .automatic)
    }

    public mutating func add<Type>(_ newValue: Any, at pathElements: PathElement..., as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try add(newValue, at: pathElements, as: type)
    }

    // MARK: Export

    public func exportData() throws -> Data {
        try F.serialize(value: value)
    }

    public func exportString() throws -> String {
        let data = try exportData()
        guard let string = String(data: data, encoding: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        return string
    }
}
