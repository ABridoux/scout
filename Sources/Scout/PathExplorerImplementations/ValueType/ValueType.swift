//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public indirect enum ValueType<Format: CodableFormat> {

    public typealias ArrayValue = [ValueType]
    public typealias DictionaryValue = [String: ValueType]

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
    case keysList([String])
    case slice(ArrayValue)
    case filter(DictionaryValue)
}

extension ValueType {

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

extension ValueType: Hashable {}

// MARK: - Codable

extension ValueType: Codable {

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

    private static func decodeSingleValue(from container: SingleValueDecodingContainer) -> ValueType? {
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

extension ValueType {

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
            self = try .dictionary(dict.mapValues { try ValueType(value: $0) })
        } else if let array = value as? [Any] {
            self = try .array(array.map { try ValueType(value: $0) })
        }

        throw PathExplorerError.invalidValue("The value \(value) cannot be serialized")
    }
}

// MARK: - Expressible literal

extension ValueType: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension ValueType: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension ValueType: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension ValueType: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self  = .bool(value)
    }
}

extension ValueType: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: ValueType...) {
        self = .array(elements)
    }
}

extension ValueType: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, ValueType)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

// MARK: - Convenience

extension ValueType {

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

    public var dict: DictionaryValue? {
        switch self {
        case .dictionary(let dict), .filter(let dict): return dict
        default: return nil
        }
    }
}

// MARK: - CustomStringConvertible

extension ValueType: CustomStringConvertible {

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
