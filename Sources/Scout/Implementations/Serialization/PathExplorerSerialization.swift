//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// PathExplorer struct which uses a serializer to parse data: Json and Plist
public struct PathExplorerSerialization<F: SerializationFormat>: PathExplorer {

    // MARK: - Properties

    var value: Any

    var isDictionary: Bool { value is DictionaryValue }
    var isArray: Bool { value is ArrayValue }

    /// `true` if the value is an array or a dictionary and is empty
    var isEmpty: Bool { isValueEmpty(value) }

    /// If `false`, the empty dicitionaries or array will be removed rather than set. Default is `true`
    var allowEmptyGroups = true

    /// `true` if the explorer has been folded
    var isFolded = false

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
            fatalError("Serialiation format not recognized. Allowed: JsonFormat and PlistFormat")
        }

    }

    /// `Path` in the data leading to this sub path explorer
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

    public mutating func delete(_ path: PathElementRepresentable..., deleteIfEmpty: Bool = false) throws {
        try delete(Path(path), deleteIfEmpty: deleteIfEmpty)
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

        guard var string = String(data: data, encoding: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        if isFolded {
            string = string.replacingOccurrences(of: F.foldedRegexPattern, with: "...", options: .regularExpression)
        }

        guard format == .json else { return string }

        if #available(OSX 10.15, *) {
            // the without-backslash option is available
            return string
        } else {
            // we have to remvove the back slashes
            return string.replacingOccurrences(of: "\\", with: "")
        }
    }

    public mutating func fold(upTo level: Int) {
        isFolded = true

        guard level >= 0 else {
            if isArray {
                value = [Self.foldedMark]
            } else if isDictionary {
                value = [Self.foldedKey: Self.foldedMark]
            }
            return
        }

        if let array = value as? ArrayValue {
            var newArray = ArrayValue()
            for (index, element) in array.enumerated() {
                var pathExplorer = PathExplorerSerialization(value: element, path: readingPath.appending(index))
                pathExplorer.fold(upTo: level - 1)
                newArray.append(pathExplorer.value)
            }

            value = newArray

        } else if let dict = value as? DictionaryValue {
            var newDict = [String: Any]()
            for (key, element) in dict {
                var pathExplorer = PathExplorerSerialization(value: element, path: readingPath.appending(key))
                pathExplorer.fold(upTo: level - 1)
                newDict[key] = pathExplorer.value
            }

            value = newDict
        }
    }

    // MARK: Conversion

    public func convertValue<Type: KeyAllowedType>(to type: KeyType<Type>) throws -> Type {
        if let value = value as? Type {
            return value
        } else {
            throw PathExplorerError.valueConversionError(value: String(describing: value), type: String(describing: Type.self))
        }
    }

    // MARK: Helpers

    /// If the given value is an array or a dictionary, check it's emptyness. Returns `false` otherwise.
    func isValueEmpty(_ value: Any) -> Bool {
        if let array = value as? ArrayValue {
            return array.isEmpty
        } else if let dict = value as? DictionaryValue {
            return dict.isEmpty
        } else {
            return false
        }
    }

    func isGroup(value: Any) -> Bool {
        value is ArrayValue || value is DictionaryValue || false
    }
}
