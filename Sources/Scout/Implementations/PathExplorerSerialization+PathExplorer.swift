import Foundation

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

    public func get<T: KeyAllowedType>(_ path: Path, as type: KeyType<T>) throws -> T {
        try T(value: get(path).value)
    }

    public func get<T: KeyAllowedType>(_ pathElements: PathElement..., as type: KeyType<T>) throws -> T {
        try T(value: get(pathElements).value)
    }

    // MARK: Set

    public mutating func set(_ path: Path, to newValue: Any) throws {
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

        guard F.self == JsonFormat.self else { return string }

        if #available(OSX 10.15, *) {
            // the without backslash option is available
            return string
        } else {
            // we have to remvove the back slashes
            return string.replacingOccurrences(of: "\\", with: "")
        }
    }
}
