//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValueDecoder {

    struct Container<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey]
        var allKeys: [Key] = []
        let value: ExplorerValue
        let decoder: ExplorerValueDecoder

        init(value: ExplorerValue, codingPath: [CodingKey], decoder: ExplorerValueDecoder) {
            self.value = value
            self.codingPath = codingPath
            self.decoder = decoder

            if let keys = try? value.get(.keysList).array(of: String.self) {
                allKeys = keys.compactMap(Key.init)
            }
        }

        func contains(_ key: Key) -> Bool {
            switch value {
            case .dictionary(let dict):
                return dict.keys.contains(key.stringValue)
            default: return false
            }
        }

        func decodeNil(forKey key: Key) throws -> Bool {
            (try? valueFor(key: key)) != nil
        }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try valueFor(key: key)
                .bool
                .unwrapOrThrow(.typeMismatch(Bool.self, codingPath: codingPath + [key]))
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try valueFor(key: key)
                .string
                .unwrapOrThrow(.typeMismatch(String.self, codingPath: codingPath + [key]))
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try valueFor(key: key)
                .double
                .unwrapOrThrow(.typeMismatch(Double.self, codingPath: codingPath + [key]))
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try Float(valueFor(key: key)
                .double
                .unwrapOrThrow(.typeMismatch(Float.self, codingPath: codingPath + [key]))
            )
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(Int.self, codingPath: codingPath + [key]))
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try Int8(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(Int8.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try Int16(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(Int16.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try Int32(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(Int32.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try Int64(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(Int64.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try UInt(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(UInt.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try UInt8(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(UInt8.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try UInt16(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(UInt16.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try UInt32(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(UInt32.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try UInt64(valueFor(key: key)
                .int
                .unwrapOrThrow(.typeMismatch(UInt64.self, codingPath: codingPath + [key])))
        }

        func decode(_ type: Data.Type, forKey key: Key) throws -> Data {
            try valueFor(key: key)
                .data
                .unwrapOrThrow(.typeMismatch(Data.self, codingPath: codingPath + [key]))
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            let value = try valueFor(key: key)

            if T.self == Data.self {
                return try decode(Data.self, forKey: key) as! T
            }

            let decoder = ExplorerValueDecoder(value, codingPath: codingPath + [key])
            return try T(from: decoder)
        }

        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            let value = try valueFor(key: key)
            return KeyedDecodingContainer(Container<NestedKey>(value: value, codingPath: codingPath + [key], decoder: decoder))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            let value = try valueFor(key: key)
            let array = try value.array.unwrapOrThrow(.typeMismatch([ExplorerValue].self, codingPath: codingPath + [key]))
            return UnkeyedContainer(array: array, codingPath: codingPath, decoder: decoder)
        }

        func superDecoder() throws -> Decoder {
            decoder
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            decoder
        }
    }
}

extension ExplorerValueDecoder.Container {

    func valueFor(key: Key) throws -> ExplorerValue {
        guard
            let dict = value.dictionary,
            let value = dict[key.stringValue]
        else {
            throw DecodingError.keyNotFound(
                key,
                DecodingError.Context(codingPath: codingPath, debugDescription: "No key with name \(key.stringValue) could be found"))
        }

        return value
    }
}
