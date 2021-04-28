//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout

public indirect enum ValueType: Equatable {
    case string(String)
    case real(String)
    case keyName(String)
    case automatic(String)
    case dictionary([String: ValueType])
    case array([ValueType])
    case error(String)
}

extension ValueType {

    var string: String? {
        switch self {
        case .string(let string), .real(let string), .automatic(let string):
            return string
        default:
            return nil
        }
    }

    var dictionary: [String: ValueType]? {
        if case let .dictionary(dict) = self {
            return dict
        }
        return nil
    }

    var array: [ValueType]? {
        if case let .array(array) = self {
            return array
        }
        return nil
    }

    var firstError: String? {
        switch self {
        case .error(let description): return description
        case .automatic, .string, .keyName, .real: return nil
        case .dictionary(let dict):
            return dict.lazy.compactMap { $0.value.firstError }.first
        case .array(let array):
            return array.lazy.compactMap(\.firstError).first
        }
    }
}

extension ValueType: ExplorerValueRepresentable {

    public func explorerValue() throws -> ExplorerValue {
        switch self {
        case .string(let string):
            return .string(string)

        case .real(let real):
            guard let double = Double(real) else {
                throw CLTCoreError.valueConversion(value: real, type: "Double/Real")
            }
            return .double(double)

        case .automatic(let string):
            return .init(fromSingle: string)

        case .keyName:
            throw CLTCoreError.wrongUsage("A keyName value cannot be used here")

        case .dictionary(let dict):
            return try .dictionary(dict.mapValues { try $0.explorerValue() })

        case .array(let array):
            return try .array(array.map { try $0.explorerValue() })

        case .error(let description):
            throw CLTCoreError.wrongUsage(description)
        }
    }
}

extension ValueType: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = ValueType

    public init(dictionaryLiteral elements: (String, ValueType)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension ValueType: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = ValueType

    public init(arrayLiteral elements: ValueType...) {
        self = .array(elements)
    }
}
