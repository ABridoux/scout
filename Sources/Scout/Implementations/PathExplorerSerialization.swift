import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat>: PathExplorer {

    // MARK: - Properties

    var value: Any

    public var string: String? { value as? String }
    public var bool: Bool? { value as? Bool }
    public var int: Int? { value as? Int }
    public var real: Double? { value as? Double }

    var isDictionary: Bool { value is [String: Any] }
    var isArray: Bool { value is [Any] }

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

    // MARK: Public subscripts

    public func get(_ path: Path) throws -> Self {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        return currentPathExplorer
    }

    public func get(_ pathElements: PathElement...) throws -> Self {
        try get(pathElements)
    }

    public mutating func set(_ path: [PathElement], to newValue: Any) throws {
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

    public mutating func set(_ pathElements: PathElement..., to newValue: Any) throws {
        try set(pathElements, to: newValue)
    }

    // MARK: Subscript helpers

    func get(for key: String) throws -> Self {
        guard let dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(String(describing: value))
        }

        guard let childValue = dict[key] else {
            throw PathExplorerError.subscriptMissingKey(key)
        }

        return PathExplorerSerialization(value: childValue)
    }

    mutating func set(key: String, to newValue: Any) throws {
        guard var dict = value as? [String: Any] else {
            throw PathExplorerError.dictionarySubscript(String(describing: value))
        }

        dict[key] = try convert(newValue)
        value = dict
    }

    func get(at index: Int) throws -> Self {
        guard let array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(String(describing: value))
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
        }

        return PathExplorerSerialization(value: array[index])
    }

    mutating func set(index: Int, to newValue: Any) throws {
        guard var array = value as? [Any] else {
            throw PathExplorerError.arraySubscript(String(describing: value))
        }

        guard array.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: array.count)
        }

        array[index] = try convert(newValue)
        value = array
    }

    func get(element pathElement: PathElement) throws -> Self {
        if let stringElement = pathElement as? String {
            return try get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return try get(at: intElement)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
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
