//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - SingleValueContainer

extension ExplorerValueDecoder {

    struct SingleValueContainer: SingleValueDecodingContainer {

        // MARK: Properties

        let value: ExplorerValue
        var codingPath: [CodingKey]
        let decoder: ExplorerValueDecoder
    }
}

// MARK: - Nil

extension ExplorerValueDecoder.SingleValueContainer {

    func decodeNil() -> Bool { false }
}

// MARK: - Scalar

extension ExplorerValueDecoder.SingleValueContainer {

    func decode(_ type: Bool.Type) throws -> Bool {
        try value.bool.unwrapOrThrow(.typeMismatch(Bool.self, codingPath: codingPath))
    }

    func decode(_ type: String.Type) throws -> String {
        try value.string.unwrapOrThrow(.typeMismatch(String.self, codingPath: codingPath))
    }

    func decode(_ type: Double.Type) throws -> Double {
        try value.double.unwrapOrThrow(.typeMismatch(Double.self, codingPath: codingPath))
    }

    func decode(_ type: Float.Type) throws -> Float {
        try Float(value.double.unwrapOrThrow(.typeMismatch(Float.self, codingPath: codingPath)))
    }

    func decode(_ type: Int.Type) throws -> Int {
        try value.int.unwrapOrThrow(.typeMismatch(Int.self, codingPath: codingPath))
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        try Int8(value.int.unwrapOrThrow(.typeMismatch(Int8.self, codingPath: codingPath)))
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        try Int16(value.int.unwrapOrThrow(.typeMismatch(Int16.self, codingPath: codingPath)))
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        try Int32(value.int.unwrapOrThrow(.typeMismatch(Int32.self, codingPath: codingPath)))
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        try Int64(value.int.unwrapOrThrow(.typeMismatch(Int64.self, codingPath: codingPath)))
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        try UInt(value.int.unwrapOrThrow(.typeMismatch(UInt.self, codingPath: codingPath)))
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        try UInt8(value.int.unwrapOrThrow(.typeMismatch(UInt8.self, codingPath: codingPath)))
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        try UInt16(value.int.unwrapOrThrow(.typeMismatch(UInt16.self, codingPath: codingPath)))
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        try UInt32(value.int.unwrapOrThrow(.typeMismatch(UInt32.self, codingPath: codingPath)))
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        try UInt64(value.int.unwrapOrThrow(.typeMismatch(UInt64.self, codingPath: codingPath)))
    }

    func decode(_ type: Data.Type) throws -> Data {
        try value.data.unwrapOrThrow(.typeMismatch(Data.self, codingPath: codingPath))
    }

    func decode(_ type: Date.Type) throws -> Date {
        try value.date.unwrapOrThrow(.typeMismatch(Date.self, codingPath: codingPath))
    }
}

// MARK: - Decodable

extension ExplorerValueDecoder.SingleValueContainer {

    func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
        if T.self == Data.self {
            return try decode(Data.self) as! T
        }

        if T.self == Date.self {
            return try decode(Date.self) as! T
        }

        if T.self == Date.self {
            return try decode(Date.self) as! T
        }

        let decoder = ExplorerValueDecoder(value, codingPath: codingPath)
        return try T(from: decoder)
    }
}
