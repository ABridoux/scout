//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValueEncoder {

    struct UnkeyedContainer: UnkeyedEncodingContainer {

        var codingPath: [CodingKey]
        let encoder: ExplorerValueEncoder
        let path: Path
        var count = 0

        mutating func encodeNil() throws {}

        mutating func encode(_ value: Bool) throws {
            try encoder.value.add(.bool(value), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: String) throws {
            try encoder.value.add(.string(value), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Double) throws {
            try encoder.value.add(.double(value), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Float) throws {
            try encoder.value.add(.double(Double(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Int) throws {
            try encoder.value.add(.int(value), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Int8) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Int16) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Int32) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Int64) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: UInt) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: UInt8) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: UInt16) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: UInt32) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: UInt64) throws {
            try encoder.value.add(.int(Int(value)), at: path.appending(.count))
            count += 1
        }

        mutating func encode(_ value: Data) throws {
            try encoder.value.add(.data(value), at: path.appending(.count))
            count += 1
        }

        mutating func encode<T>(_ value: T) throws where T : Encodable {
            if let data = value as? Data {
                try encode(data)
                return
            }

            let newEncoder = ExplorerValueEncoder(codingPath: codingPath)
            try value.encode(to: newEncoder)
            try encoder.value.add(newEncoder.value, at: path.appending(.count))
            count += 1
        }

        mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
            defer { count += 1 }
            return KeyedEncodingContainer(Container<NestedKey>(codingPath: codingPath, encoder: encoder, path: path.appending(.count)))
        }

        mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            defer { count += 1 }
            return UnkeyedContainer(codingPath: codingPath, encoder: encoder, path: path.appending(.count))
        }

        mutating func superEncoder() -> Encoder {
            encoder
        }
    }
}
