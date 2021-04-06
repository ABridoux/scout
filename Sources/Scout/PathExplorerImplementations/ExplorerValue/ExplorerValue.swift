//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// The values a `PathExplorer` can take
public indirect enum ExplorerValue {

    public typealias ArrayValue = [ExplorerValue]
    public typealias DictionaryValue = [String: ExplorerValue]
    typealias SlicePath = Slice<Path>

    // standard
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case data(Data)
    case array(ArrayValue)
    case dictionary(DictionaryValue)

    // special
    case count(Int)
    case keysList(Set<String>)
    case slice(ArrayValue)
    case filter(DictionaryValue)
}

extension ExplorerValue {

    var isSingle: Bool {
        !isGroup
    }

    var isGroup: Bool {
        switch self {
        case .array, .dictionary: return true
        default: return false
        }
    }

    var isDictionary: Bool {
        guard case .dictionary = self else { return false }
        return true
    }

    var isArray: Bool {
        guard case .array = self else { return false }
        return true
    }

    var isEmpty: Bool {
        switch self {
        case .array(let array): return array.isEmpty
        case .dictionary(let dict): return dict.isEmpty
        default:
            return false
        }
    }
}

// MARK: - Hashable

extension ExplorerValue: Hashable {}

// MARK: - Codable

extension ExplorerValue: Codable {

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let value = Self.decodeSingleValue(from: container) {
            self = value
        } else if let dict = try? DictionaryValue(from: decoder) {
            self = .dictionary(dict)
        } else {
            let array = try ArrayValue(from: decoder)
            self = .array(array)
        }
    }

    private static func decodeSingleValue(from container: SingleValueDecodingContainer) -> ExplorerValue? {
        if let int = try? container.decode(Int.self) {
            return .int(int)
        } else if let double = try? container.decode(Double.self) {
            return .double(double)
        } else if let string = try? container.decode(String.self) {
            return .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            return .bool(bool)
        } else if let data = try? container.decode(Data.self) {
            return .data(data)
        }

        return nil
    }

    public func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()

        switch self {
        case .int(let int), .count(let int): try singleValueContainer.encode(int)
        case .double(let double): try singleValueContainer.encode(double)
        case .string(let string): try singleValueContainer.encode(string)
        case .bool(let bool): try singleValueContainer.encode(bool)
        case .data(let data): try singleValueContainer.encode(data)
        case .array(let array), .slice(let array): try array.encode(to: encoder)
        case .dictionary(let dict), .filter(let dict): try dict.encode(to: encoder)
        case .keysList(let array): try array.encode(to: encoder)
        }
    }
}

// MARK: - Any

extension ExplorerValue {

    init(value: Any) throws {
        if let int = value as? Int {
            self = .int(int)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let string = value as? String {
            self = .string(string)
        } else if let bool = value as? Bool {
            self = .bool(bool)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let dict = value as? [String: Any] {
            self = try .dictionary(dict.mapValues { try ExplorerValue(value: $0) })
        } else if let array = value as? [Any] {
            self = try .array(array.map { try ExplorerValue(value: $0) })
        } else {
            throw PathExplorerError.invalidValue("The value \(value) cannot be serialized")
        }
    }
}

// MARK: - Expressible literal

extension ExplorerValue: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension ExplorerValue: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension ExplorerValue: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension ExplorerValue: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self  = .bool(value)
    }
}

extension ExplorerValue: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: ExplorerValue...) {
        self = .array(elements)
    }
}

extension ExplorerValue: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, ExplorerValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

// MARK: - Convenience

extension ExplorerValue {

    func array(_ value: ArrayValue) -> Self { .array(value) }
    func dictionary(_ value: DictionaryValue) -> Self { .dictionary(value) }
    func keysList(_ value: Set<String>) -> Self { .keysList(value) }
    func slice(_ value: ArrayValue) -> Self { .slice(value) }
    func filter(_ value: DictionaryValue) -> Self { .filter(value) }
}

extension ExplorerValue {

    /// Associated value as `Any`
    var any: Any {
        switch self {
        case .string(let string): return string
        case .int(let int), .count(let int): return int
        case .double(let double): return double
        case .bool(let bool): return bool
        case .data(let data): return data
        case .array(let array), .slice(let array): return array
        case .dictionary(let dict), .filter(let dict): return dict
        case .keysList(let keys): return keys
        }
    }

    public var int: Int? {
        switch self {
        case .int(let int), .count(let int): return int
        default: return nil
        }
    }

    public var double: Double? {
        guard case let .double(double) = self else { return nil }
        return double
    }

    public var real: Double? { double }

    public var string: String? {
        guard case let .string(string) = self else { return nil }
        return string
    }

    public var bool: Bool? {
        guard case let .bool(bool) = self else { return nil }
        return bool
    }

    public var data: Data? {
        guard case let .data(data) = self else { return nil }
        return data
    }

    public var array: ArrayValue? {
        switch self {
        case .array(let array), .slice(let array): return array
        case .keysList(let array): return array.map { .string($0) }
        default: return nil
        }
    }

    public var dictionary: DictionaryValue? {
        switch self {
        case .dictionary(let dict), .filter(let dict): return dict
        default: return nil
        }
    }

    public func array<T: ExplorerValueCreatable>(of type: T.Type) throws -> [T] {
        let array = try self.array.unwrapOrThrow(.mismatchingType(ArrayValue.self, value: self))
        return try array.map { try T(from: $0) }
    }

    public func dictionary<T: ExplorerValueCreatable>(of type: T.Type) throws -> [String: T] {
        let dict = try dictionary.unwrapOrThrow(.mismatchingType(DictionaryValue.self, value: self))
        return try dict.mapValues { try T(from: $0) }
    }
}

// MARK: - CustomStringConvertible

extension ExplorerValue: CustomStringConvertible {

    public var description: String {
        switch self {
        case .int(let int), .count(let int): return int.description
        case .double(let double): return double.description
        case .string(let string): return string
        case .bool(let bool): return bool.description
        case .data(let data): return data.base64EncodedString()
        case .array(let array), .slice(let array):
            let elements = array.map(\.description).joined(separator: ",")
            return "[\(elements)]"
        case .dictionary(let dict), .filter(let dict):
            let elements = dict.map { "\($0.key): \($0.value)" }.joined(separator: ",")
            return "[\(elements)]"
        case .keysList(let array):
            return "[\(array.joined(separator: ","))]"
        }
    }
}

// MARK: - Helpers and Operators

extension PathExplorerBis {

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd<T>(_ element: PathElementRepresentable, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd(_ element: PathElementRepresentable, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd<T>(_ element: PathElement, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd(_ element: PathElement, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// do/catch on the provided block to catch a `ValueTypeError` and set the provided path on it
    func doSettingPath(_ path: Slice<Path>, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.with(path: path)
        }
    }

    /// do/catch on the provided block to catch a `ValueTypeError` and set the provided path on it
    func doSettingPath<T>(_ path: Slice<Path>, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.with(path: path)
        }
    }
}

infix operator <^>

/// Apply the left function to the right operand
/// - note: Mainly used as synthetic sugar to avoid over use of brackets
func <^><A>(lhs: (A) -> ExplorerValue, rhs: A) -> ExplorerValue { lhs(rhs) }

extension ExplorerValue: EquatablePathExplorer {
    public init(value: ExplorerValue) {
        self = value
    }

    public mutating func set<Type>(_ path: Path, to newValue: ExplorerValue, as type: KeyTypes.KeyType<Type>) throws where Type: KeyAllowedType {

    }

    public var debugDescription: String { description }
}
