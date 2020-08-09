//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat>: PathExplorer {

    // MARK: - Constants

    typealias DictionaryValue = [String: Any]
    typealias ArrayValue = [Any]

    // MARK: - Properties

    var value: Any

    var isDictionary: Bool { value is DictionaryValue }
    var isArray: Bool { value is ArrayValue }

    // MARK: PathExplorer

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

    public func get(_ path: PathElementRepresentable...) throws -> Self {
        try get(Path(path))
    }

    public func get<T: KeyAllowedType>(_ path: Path, as type: KeyType<T>) throws -> T {
        try T(value: get(path).value)
    }

    public func get<T: KeyAllowedType>(_ path: PathElementRepresentable..., as type: KeyType<T>) throws -> T {
        try T(value: get(Path(path)).value)
    }

    // MARK: Set

    public mutating func set(_ path: Path, to newValue: Any) throws {
        try set(path, to: newValue, as: .automatic)
    }

    public mutating func set<Type: KeyAllowedType>(_ path: PathElementRepresentable..., to newValue: Any, as type: KeyType<Type>) throws {
        try set(Path(path), to: newValue, as: type)
    }

    public mutating func set(_ path: PathElementRepresentable..., to newValue: Any) throws {
        try set(Path(path), to: newValue, as: .automatic)
    }

    // -- Set key name

    public mutating func set(_ path: PathElementRepresentable..., keyNameTo newKeyName: String) throws {
        try set(Path(path), keyNameTo: newKeyName)
    }

    // MARK: Delete

    public mutating func delete(_ path: PathElementRepresentable...) throws {
        try delete(Path(path))
    }

    // MARK: Add

    public mutating func add(_ newValue: Any, at path: Path) throws {
        try add(newValue, at: path, as: .automatic)
    }

    public mutating func add(_ newValue: Any, at path: PathElementRepresentable...) throws {
        try add(newValue, at: Path(path), as: .automatic)
    }

    public mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: PathElementRepresentable..., as type: KeyType<Type>) throws {
        try add(newValue, at: Path(path), as: type)
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
