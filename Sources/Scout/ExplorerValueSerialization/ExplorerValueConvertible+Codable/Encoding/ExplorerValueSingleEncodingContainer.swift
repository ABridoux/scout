//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - SingleContainer

extension ExplorerValueEncoder {

    struct SingleContainer: SingleValueEncodingContainer {

        // MARK: Properties

        var codingPath: [CodingKey]
        let encoder: ExplorerValueEncoder
        let path: Path
    }
}

// MARK: - Nil

extension ExplorerValueEncoder.SingleContainer {

    mutating func encodeNil() throws {}
}

// MARK: - Scalar

extension ExplorerValueEncoder.SingleContainer {

    mutating func encode(_ value: Bool) throws {
        try encoder.value.set(path, to: .bool(value))
    }

    mutating func encode(_ value: String) throws {
        try encoder.value.set(path, to: .string(value))
    }

    mutating func encode(_ value: Double) throws {
        try encoder.value.set(path, to: .double(value))
    }

    mutating func encode(_ value: Float) throws {
        try encoder.value.set(path, to: .double(Double(value)))
    }

    mutating func encode(_ value: Int) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: Int8) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: Int16) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: Int32) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: Int64) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: UInt) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: UInt8) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: UInt16) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: UInt32) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: UInt64) throws {
        try encoder.value.set(path, to: .int(Int(value)))
    }

    mutating func encode(_ value: Data) throws {
        try encoder.value.set(path, to: .data(value))
    }

    mutating func encode(_ value: Date) throws {
        try encoder.value.set(path, to: .date(value))
    }
}

// MARK: - Encodable

extension ExplorerValueEncoder.SingleContainer {

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        if let data = value as? Data {
            try encode(data)
            return
        }

        if let date = value as? Date {
            try encode(date)
            return
        }

        let newEncoder = ExplorerValueEncoder(codingPath: codingPath)
        try value.encode(to: encoder)
        try encoder.value.set(path, to: newEncoder.value)
    }
}
