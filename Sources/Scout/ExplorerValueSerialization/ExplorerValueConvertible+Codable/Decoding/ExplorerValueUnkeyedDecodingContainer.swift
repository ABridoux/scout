//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValueDecoder {

    struct UnkeyedContainer: UnkeyedDecodingContainer {
        let array: [ExplorerValue]
        var codingPath: [CodingKey]
        let decoder: ExplorerValueDecoder
        var count: Int? { array.count }
        var isAtEnd: Bool { currentIndex == count }
        var currentIndex = 0

        mutating func decodeNil() throws -> Bool { false }

        mutating func decode(_ type: Bool.Type) throws -> Bool {
            let value = try array[currentIndex].bool.unwrapOrThrow(.typeMismatch(Bool.self, codingPath: codingPath))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: String.Type) throws -> String {
            let value = try array[currentIndex].string.unwrapOrThrow(.typeMismatch(String.self, codingPath: codingPath))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Double.Type) throws -> Double {
            let value = try array[currentIndex].double.unwrapOrThrow(.typeMismatch(Double.self, codingPath: codingPath))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Float.Type) throws -> Float {
            let value = try Float(array[currentIndex].double.unwrapOrThrow(.typeMismatch(Float.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Int.Type) throws -> Int {
            let value = try array[currentIndex].int.unwrapOrThrow(.typeMismatch(Int.self, codingPath: codingPath))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            let value = try Int8(array[currentIndex].int.unwrapOrThrow(.typeMismatch(Int8.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            let value = try Int16(array[currentIndex].int.unwrapOrThrow(.typeMismatch(Int16.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            let value = try Int32(array[currentIndex].int.unwrapOrThrow(.typeMismatch(Int32.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            let value = try Int64(array[currentIndex].int.unwrapOrThrow(.typeMismatch(Int64.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: UInt.Type) throws -> UInt {
            let value = try UInt(array[currentIndex].int.unwrapOrThrow(.typeMismatch(UInt.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            let value = try UInt8(array[currentIndex].int.unwrapOrThrow(.typeMismatch(UInt8.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            let value = try UInt16(array[currentIndex].int.unwrapOrThrow(.typeMismatch(UInt16.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            let value = try UInt32(array[currentIndex].int.unwrapOrThrow(.typeMismatch(UInt32.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            let value = try UInt64(array[currentIndex].int.unwrapOrThrow(.typeMismatch(UInt64.self, codingPath: codingPath)))
            currentIndex += 1
            return value
        }

        mutating func decode(_ type: Data.Type) throws -> Data {
            let value = try array[currentIndex].data.unwrapOrThrow(.typeMismatch(Data.self, codingPath: codingPath))
            currentIndex += 1
            return value
        }

        mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            if T.self == Data.self {
                return try decode(Data.self) as! T
            }

            let decoder = ExplorerValueDecoder(array[currentIndex], codingPath: codingPath)
            let decoded = try T(from: decoder)
            currentIndex += 1
            return decoded
        }

        mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            let value = array[currentIndex]
            return KeyedDecodingContainer(Container<NestedKey>(value: value, codingPath: codingPath, decoder: decoder))
        }

        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let value = array[currentIndex]
            let array = try value.array.unwrapOrThrow(.typeMismatch([ExplorerValue].self, codingPath: codingPath))
            return UnkeyedContainer(array: array, codingPath: codingPath, decoder: decoder)
        }

        mutating func superDecoder() throws -> Decoder {
            decoder
        }
    }
}
