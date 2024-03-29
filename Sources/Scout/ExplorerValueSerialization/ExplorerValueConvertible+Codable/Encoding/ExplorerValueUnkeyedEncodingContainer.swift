//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - UnkeyedContainer

extension ExplorerValueEncoder {

    struct UnkeyedContainer: UnkeyedEncodingContainer {

        // MARK: Properties

        var codingPath: [CodingKey]
        let encoder: ExplorerValueEncoder
        let path: Path
        var count = 0
    }
}

// MARK: - Nil

extension ExplorerValueEncoder.UnkeyedContainer {

    mutating func encodeNil() throws {}
}

// MARK: - Scalar

extension ExplorerValueEncoder.UnkeyedContainer {

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

    mutating func encode(_ value: Date) throws {
        try encoder.value.add(.date(value), at: path.appending(.count))
        count += 1
    }
}

// MARK: - Encodable

extension ExplorerValueEncoder.UnkeyedContainer {

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
        try value.encode(to: newEncoder)
        try encoder.value.add(newEncoder.value, at: path.appending(.count))
        count += 1
    }
}

// MARK: - Nested containers

extension ExplorerValueEncoder.UnkeyedContainer {

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        defer { count += 1 }
        return KeyedEncodingContainer(
            ExplorerValueEncoder.Container<NestedKey>(
                codingPath: codingPath,
                encoder: encoder,
                path: path.appending(.count)
            )
        )
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        defer { count += 1 }
        return ExplorerValueEncoder.UnkeyedContainer(
            codingPath: codingPath,
            encoder: encoder,
            path: path.appending(.count)
        )
    }
}

// MARK: - Super

extension ExplorerValueEncoder.UnkeyedContainer {

    mutating func superEncoder() -> Encoder {
        encoder
    }
}
