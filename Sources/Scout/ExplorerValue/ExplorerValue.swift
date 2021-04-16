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

    // single
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case data(Data)

    // group
    case array(ArrayValue)
    case dictionary(DictionaryValue)

    // group sample
    case slice(ArrayValue)
    case filter(DictionaryValue)
}

extension ExplorerValue {

    public var isSingle: Bool { !isGroup }

    public var isGroup: Bool {
        switch self {
        case .array, .dictionary, .filter, .slice: return true
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

    var isNull: Bool {
        if case let .string(string) = self, string == "null" {
            return true
        }
        return false
    }
}

// MARK: - Hashable

extension ExplorerValue: Hashable {}

// MARK: - Codable

extension ExplorerValue: Codable {

    private struct ExplorerCodingKey: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = String(intValue)
        }
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: ExplorerCodingKey.self) {
            var dict = DictionaryValue()
            try container.allKeys.forEach { (key) in
                let value = try container.decode(ExplorerValue.self, forKey: key)
                guard !value.isNull else { return }
                dict[key.stringValue] = value
            }
            self = .dictionary(dict)

        } else if var container = try? decoder.unkeyedContainer() {
            var array = ArrayValue()
            while !container.isAtEnd {
                let value = try container.decode(ExplorerValue.self)
                guard !value.isNull else { continue }
                array.append(value)
            }
            self = .array(array)

        } else {
            let container = try decoder.singleValueContainer()
            self = try .decodeSingleValue(from: container)
        }
    }

    private static func decodeSingleValue(from container: SingleValueDecodingContainer) throws -> ExplorerValue {
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
        } else {
            if container.decodeNil() {
                return .string("null")
            } else {
                throw ExplorerError(description: "Unable to decode single value in data. \(container.codingPath)")
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .int(let int):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(int)

        case .double(let double):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(double)

        case .string(let string):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(string)

        case .bool(let bool):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(bool)

        case .data(let data):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(data)

        case .array(let array), .slice(let array):
            try array.encode(to: encoder)

        case .dictionary(let dict), .filter(let dict):
            try dict.encode(to: encoder)
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
            throw ExplorerError.invalid(value: value)
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
    func slice(_ value: ArrayValue) -> Self { .slice(value) }
    func filter(_ value: DictionaryValue) -> Self { .filter(value) }
}

extension ExplorerValue {

    /// Associated value as `Any`
    var any: Any {
        switch self {
        case .string(let string): return string
        case .int(let int): return int
        case .double(let double): return double
        case .bool(let bool): return bool
        case .data(let data): return data
        case .array(let array), .slice(let array): return array
        case .dictionary(let dict), .filter(let dict): return dict
        }
    }

    public var int: Int? {
        switch self {
        case .int(let int): return int
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
        case .int(let int): return int.description
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
        }
    }
}

extension ExplorerValue: CustomDebugStringConvertible {

    public var debugDescription: String { description }
}

// MARK: - Helpers and Operators

precedencegroup SequencePrecedence {
    associativity: left
}

infix operator <^>: SequencePrecedence

/// Apply the left function to the right operand
/// - note: Mainly used as synthetic sugar to avoid over use of brackets
func <^><A, B>(lhs: (A) -> B, rhs: A) -> B { lhs(rhs) }

extension ExplorerValue: EquatablePathExplorer {
    public init(value: ExplorerValue, name: String?) {
        self = value
    }
}
