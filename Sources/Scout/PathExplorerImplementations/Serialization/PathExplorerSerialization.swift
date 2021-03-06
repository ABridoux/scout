//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// `PathExplorer` which uses a serialiser to parse data: Json, Plist and Yaml
public struct PathExplorerSerialization<F: SerializationFormat>: PathExplorer {

    // MARK: - Properties

    // MARK: State

    var value: Any

    /// If `false`, the empty dictionaries or array will be removed rather than set. Default is `true`
    var allowEmptyGroups = true

    /// `true` if the explorer has been folded
    var isFolded = false

    // MARK: Computed

    var isDictionary: Bool { value is DictionaryValue }
    var isArray: Bool { value is ArrayValue }

    /// `true` if the value is an array or a dictionary and is empty
    var isEmpty: Bool { isValueEmpty(value) }

    // MARK: PathExplorer

    public var string: String? { value as? String }
    public var bool: Bool? { value as? Bool }
    public var int: Int? { value as? Int }
    public var real: Double? { value as? Double }

    public func array<Value>(_ type: KeyTypes.Get.ValueType<Value>) -> [Value]? {
        var children = [Any]()
        if let dict = value as? DictionaryValue {
            children = Array(dict.values)
        } else if let array = value as? ArrayValue {
            children = array
        }

        for child in children where isGroup(value: child) {
            // prevent nested values
            return nil
        }

        return value as? [Value]
    }

    public func dictionary<Value>(_ type: KeyTypes.Get.ValueType<Value>) -> [String: Value]? {
        var children = [Any]()
        if let dict = value as? DictionaryValue {
            children = Array(dict.values)
        } else if let array = value as? ArrayValue {
            children = array
        }

        for child in children where isGroup(value: child) {
            // prevent nested values
            return nil
        }

        return value as? [String: Value]
    }

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
        guard isGroup(value: value) else {
            // single values can be described
            return String(describing: value)
        }

        do {
            return try exportString()
        } catch {
            return "Unable to convert \(self) to a String. The serialization has thrown an error. Try the `exportString()` function"
        }
    }

    public var format: DataFormat { F.dataFormat }

    /// `Path` in the data leading to this sub path explorer
    public var readingPath = Path()
}

// MARK: - Initialization

extension PathExplorerSerialization {

    public init(data: Data) throws {
        let raw = try F.serialize(data: data)

        if let dict = raw as? DictionaryValue {
            value = dict
        } else if let array = raw as? ArrayValue {
            value = array
        } else {
            throw PathExplorerError.invalidData(description: "Cannot initialize a \(F.dataFormat.rawValue) object with the given data")
        }
    }

    public init(value: Any) {
        self.value = value
    }

    init(value: Any, path: Path) {
        self.value = value
        readingPath = path
    }

    public init(stringLiteral value: String) {
        self.init(value: value)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value: value)
    }

    public init(integerLiteral value: Int) {
        self.init(value: value)
    }

    public init(floatLiteral value: Double) {
        self.init(value: value)
    }
}

// MARK: - PathExplorer Functions

extension PathExplorerSerialization {

    // MARK: Get

    public func get<T: KeyAllowedType>(_ path: Path, as type: KeyTypes.KeyType<T>) throws -> T {
        try T(value: get(path).value)
    }

    // MARK: Set

    public mutating func set(_ path: Path, to newValue: Any) throws {
        try set(path, to: newValue, as: .automatic)
    }

    // MARK: Add

    public mutating func add(_ newValue: Any, at path: Path) throws {
        try add(newValue, at: path, as: .automatic)
    }

    // MARK: Fold

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

    public func convertValue<Type: KeyAllowedType>(to type: KeyTypes.KeyType<Type>) throws -> Type {
        if let value = value as? Type {
            return value
        } else {
            throw PathExplorerError.valueConversionError(value: String(describing: value), type: String(describing: Type.self))
        }
    }

    // MARK: Helpers

    /// If the given value is an array or a dictionary, check it's emptyness. Returns `false` otherwise.
    func isValueEmpty(_ value: Any) -> Bool {
        switch value {
        case let array as ArrayValue: return array.isEmpty
        case let dict as DictionaryValue: return dict.isEmpty
        default: return false
        }
    }

    /// `true` if the provided value is a group one (array or dictionary)
    func isGroup(value: Any) -> Bool {
        value is ArrayValue || value is DictionaryValue || false
    }
}
