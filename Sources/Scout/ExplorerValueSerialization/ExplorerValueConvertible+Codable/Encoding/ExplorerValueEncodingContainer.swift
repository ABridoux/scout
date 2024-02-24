//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Container

extension ExplorerValueEncoder {

    struct Container<Key: CodingKey>: KeyedEncodingContainerProtocol {

        // MARK: Properties

        var codingPath: [CodingKey]
        var encoder: ExplorerValueEncoder
        var path: Path
    }
}

// MARK: - Nil

extension ExplorerValueEncoder.Container {

    mutating func encodeNil(forKey key: Key) throws {}
}

// MARK: - Scalar

extension ExplorerValueEncoder.Container {

    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try encoder.value.add(.bool(value), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: String, forKey key: Key) throws {
        try encoder.value.add(.string(value), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Double, forKey key: Key) throws {
        try encoder.value.add(.double(value), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {
        try encoder.value.add(.double(Double(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        try encoder.value.add(.int(value), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try encoder.value.add(.int(Int(value)), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Data, forKey key: Key) throws {
        try encoder.value.add(.data(value), at: path.appending(key.stringValue))
    }

    mutating func encode(_ value: Date, forKey key: Key) throws {
        try encoder.value.add(.date(value), at: path.appending(key.stringValue))
    }
}

// MARK: - Encodable

extension ExplorerValueEncoder.Container {

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        if let data = value as? Data {
            try encode(data, forKey: key)
            return
        }

        if let data = value as? Date {
            try encode(data, forKey: key)
            return
        }

        let newEncoder = ExplorerValueEncoder()
        try value.encode(to: newEncoder)
        try encoder.value.add(newEncoder.value, at: path.appending(key.stringValue))
    }
}

// MARK: - Nested containers

extension ExplorerValueEncoder.Container {

    mutating func nestedContainer<NestedKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey>
    where NestedKey: CodingKey {
        KeyedEncodingContainer(
            ExplorerValueEncoder.Container<NestedKey>(
                codingPath: codingPath + [key], 
                encoder: encoder,
                path: path.appending(key.stringValue)
            )
        )
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        ExplorerValueEncoder.UnkeyedContainer(
            codingPath: codingPath + [key],
            encoder: encoder,
            path: path.appending(key.stringValue)
        )
    }
}

// MARK: - Super

extension ExplorerValueEncoder.Container {

    mutating func superEncoder() -> Encoder {
        encoder
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
}
