//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

indirect enum ValueType {

    typealias ArrayValue = [ValueType]
    typealias DictionaryValue = [String: ValueType]

    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case data(Data)
    case array(ArrayValue)
    case dictionary(DictionaryValue)
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
}

// MARK: - Hashable

extension ValueType: Hashable {}

// MARK: - Codable

extension ValueType: Codable {

    init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()

        switch self {
        case .int(let int): try singleValueContainer.encode(int)
        case .double(let double): try singleValueContainer.encode(double)
        case .string(let string): try singleValueContainer.encode(string)
        case .bool(let bool): try singleValueContainer.encode(bool)
        case .data(let data): try singleValueContainer.encode(data)
        case .array(let array): try array.encode(to: encoder)
        case .dictionary(let dict): try dict.encode(to: encoder)
        }
    }
}
// MARK: - Expressible literal

extension ValueType: ExpressibleByStringLiteral {

    init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension ValueType: ExpressibleByIntegerLiteral {

    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension ValueType: ExpressibleByFloatLiteral {

    init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension ValueType: ExpressibleByBooleanLiteral {

    init(booleanLiteral value: Bool) {
        self  = .bool(value)
    }
}

extension ValueType: ExpressibleByArrayLiteral {

    init(arrayLiteral elements: ValueType...) {
        self = .array(elements)
    }
}

extension ValueType: ExpressibleByDictionaryLiteral {

    init(dictionaryLiteral elements: (String, ValueType)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

// MARK: - Convenience

extension ValueType {

    static func array(_ elements: ValueType...) -> ValueType {
        return .array(elements)
    }
}

extension ValueType {

    var int: Int? {
        guard case let .int(int) = self else { return nil }
        return int
    }

    var double: Double? {
        guard case let .double(double) = self else { return nil }
        return double
    }

    var string: String? {
        guard case let .string(string) = self else { return nil }
        return string
    }

    var bool: Bool? {
        guard case let .bool(bool) = self else { return nil }
        return bool
    }

    var data: Data? {
        guard case let .data(data) = self else { return nil }
        return data
    }

    var array: ArrayValue? {
        guard case let .array(array) = self else { return nil }
        return array
    }

    var dict: DictionaryValue? {
        guard case let .dictionary(dict) = self else { return nil }
        return dict
    }
}
