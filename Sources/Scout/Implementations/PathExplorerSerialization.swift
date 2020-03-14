import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat>: PathExplorer {

    // MARK: - Properties

    var value: Any

    public var string: String? { value as? String }
    public var bool: Bool? { value as? Bool }
    public var int: Int? { value as? Int }
    public var real: Double? { value as? Double }
    public var date: Date? { value as? Date }

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

    public init(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        try self.init(data: data)
    }

    public init(value: Any) {
        self.value = value
    }

    // MARK: - Functions

    // MARK: Subscript

    public subscript(_ key: String) -> PathExplorerSerialization {
        get { get(for: key) }
        set { set(newValue, for: key) }
    }

    public subscript(_ index: Int) -> PathExplorerSerialization {
        get { get(at: index) }
        set { set(newValue, at: index) }
    }

    public subscript(_ path: PathElement...) -> PathExplorerSerialization {
        get { get(at: path) }
        set { set(newValue, at: path) }
    }

    public subscript(_ path: Path) -> PathExplorerSerialization {
        get { get(at: path) }
        set { set(newValue, at: path) }
    }

    // MARK: Subscript helpers

    private func get(for key: String) -> PathExplorerSerialization {
        guard
            let dict = value as? [String: Any],
            let childValue = dict[key]
        else {
            return self
        }

        return PathExplorerSerialization(value: childValue)
    }

    private mutating func set(_ newValue: PathExplorerSerialization, for key: String) {
        guard
            var dict = value as? [String: Any]
        else {
            return
        }
        dict[key] = newValue.value
        value = dict
    }

    private func get(at index: Int) -> PathExplorerSerialization {
        guard
            let array = value as? [Any],
            array.count > index,
            index >= 0
        else {
            return self
        }

        return PathExplorerSerialization(value: array[index])
    }

    private func get(forElement pathElement: PathElement) -> PathExplorerSerialization {
        if let stringElement = pathElement as? String {
            return get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return get(at: intElement)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
    }

    private mutating func set(_ newValue: PathExplorerSerialization, at index: Int) {
        guard
            var array = value as? [Any],
            array.count > index,
            index >= 0
        else {
            return
        }
        array[index] = newValue.value
        value = array
    }

    private func get(at pathElements: Path) -> PathExplorerSerialization {
        var currentPathExplorer = self

        pathElements.forEach {
            currentPathExplorer = currentPathExplorer.get(forElement: $0)
        }

        return currentPathExplorer
    }

    private mutating func set(_ newValue: PathExplorerSerialization?, at pathElements: [PathElement]) {
        var pathElements = pathElements

        guard
            !pathElements.isEmpty,
            let newValue = newValue
        else {
            return
        }

        let lastElement = pathElements.removeLast()
        var currentPathExplorer = self
        var pathExplorers = [currentPathExplorer]

        pathElements.forEach {
            currentPathExplorer = currentPathExplorer.get(forElement: $0)
            pathExplorers.append(currentPathExplorer)
        }

        if let lastElementString = lastElement as? String {
            currentPathExplorer.set(newValue, for: lastElementString)
        } else if let lastElementInt = lastElement as? Int {
            currentPathExplorer.set(newValue, at: lastElementInt)
        } else {
            return
        }

        for (plist, element) in zip(pathExplorers, pathElements).reversed() {
            var plist = plist
            plist[element] = currentPathExplorer
            currentPathExplorer = plist
        }

        self = currentPathExplorer
    }

    // MARK: Export

    public func exportData() throws -> Data {
        try F.serialize(value: value)
    }

    public func outputString() throws -> String? {
        let data = try exportData()
        return String(data: data, encoding: .utf8)
    }
}
