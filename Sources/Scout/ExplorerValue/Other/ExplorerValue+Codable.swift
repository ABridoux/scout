//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - ExplorerCodingKey

extension ExplorerValue: Codable {

    private struct ExplorerCodingKey: CodingKey {

        // MARK: Properties

        var stringValue: String
        var intValue: Int?

        // MARK: Init

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            self.intValue = intValue
            stringValue = String(intValue)
        }
    }
}

// MARK: - Decode

extension ExplorerValue {

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
        } else if let date = try? container.decode(Date.self) {
            return .date(date)
        } else if container.decodeNil() {
            return .string("null")
        } else {
            throw ExplorerError(description: "Unable to decode single value in data. \(container.codingPath.pathDescription)")
        }
    }
}

// MARK: - Encode

extension ExplorerValue {

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

        case .date(let date):
            var singleValueContainer = encoder.singleValueContainer()
            try singleValueContainer.encode(date)

        case .array(let array):
            try array.encode(to: encoder)

        case .dictionary(let dict):
            try dict.encode(to: encoder)
        }
    }
}
