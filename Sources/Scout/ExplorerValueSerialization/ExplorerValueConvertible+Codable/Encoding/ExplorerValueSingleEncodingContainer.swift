//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValueEncoder {

    struct SingleContainer: SingleValueEncodingContainer {
        var codingPath: [CodingKey]
        let encoder: ExplorerValueEncoder
        let path: Path

        mutating func encodeNil() throws {}

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

        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let data = value as? Data {
                try encode(data)
                return
            }

            let newEncoder = ExplorerValueEncoder(codingPath: codingPath)
            try value.encode(to: encoder)
            try encoder.value.set(path, to: newEncoder.value)
        }
    }
}
