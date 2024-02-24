//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - ExplorerValueDecoder

final class ExplorerValueDecoder: Decoder {

    // MARK: Properties

    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    let value: ExplorerValue

    // MARK: Init

    init(_ value: ExplorerValue, codingPath: [CodingKey] = []) {
        self.value = value
        self.codingPath = codingPath
    }
}

// MARK: - Containers

extension ExplorerValueDecoder {

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        KeyedDecodingContainer(Container(value: value, codingPath: codingPath, decoder: self))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let array = try value.array.unwrapOrThrow(error: valueTypeError(type: [ExplorerValue].self))
        return UnkeyedContainer(array: array, codingPath: codingPath, decoder: self)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueContainer(value: value, codingPath: codingPath, decoder: self)
    }
}

// MARK: - Error

extension ExplorerValueDecoder {

    func valueTypeError<T>(type: T.Type) -> DecodingError {
        DecodingError.typeMismatch(
            T.self,
            DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }
}
