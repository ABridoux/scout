extension PathExplorerXML: PathExplorer {
    public var string: String? { element.string.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var real: Double? { element.double }

    public var stringValue: String { element.string.trimmingCharacters(in: .whitespacesAndNewlines) }

    public var description: String { element.xml }

    public var format: DataFormat { .xml }

    // MARK: Get

    public func get(_ pathElements: PathElementRepresentable...) throws -> Self {
        try get(Path(pathElements))
    }

    public func get(_ pathElements: Path) throws  -> Self {
        var currentPathExplorer = self

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(pathElement: $0.pathValue)
        }

        return currentPathExplorer
    }

    public func get<T>(_ path: Path, as type: KeyType<T>) throws -> T where T: KeyAllowedType {
        let explorer = try get(path)

        guard let value = explorer.element.value else {
            throw PathExplorerError.underlyingError("Program error. No value at '\(path.description)' although the path is valid.")
        }
        return try T(value: value)
    }

    public func get<T>(_ pathElements: PathElementRepresentable..., as type: KeyType<T>) throws -> T where T: KeyAllowedType {
        try get(Path(pathElements), as: type)
    }

    // MARK: Set

    public mutating func set<Type>(_ path: Path, to newValue: Any, as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try set(path, to: newValue)
    }

    public mutating  func set(_ pathElements: PathElementRepresentable..., to newValue: Any) throws {
        try set(Path(pathElements), to: newValue)
    }

    public mutating func set<Type>(_ pathElements: PathElementRepresentable..., to newValue: Any, as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try set(Path(pathElements), to: newValue)
    }

    // -- Set key name

    public mutating func set(_ pathElements: PathElementRepresentable..., keyNameTo newKeyName: String) throws {
        try set(Path(pathElements), keyNameTo: newKeyName)
    }

    // MARK: Add

    public mutating func add<Type>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try add(newValue, at: path)
    }

    public mutating func add<Type>(_ newValue: Any, at pathElements: PathElementRepresentable..., as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try add(newValue, at: Path(pathElements))
    }
}
