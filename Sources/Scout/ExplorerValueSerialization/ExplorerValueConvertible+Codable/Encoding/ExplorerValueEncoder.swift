//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - ExplorerValueEncoder

final class ExplorerValueEncoder: Encoder {

    // MARK: Properties

    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var value: ExplorerValue!

    // MARK: Init

    init(codingPath: [CodingKey] = []) {
        self.codingPath = codingPath
    }
}

// MARK: - Containers

extension ExplorerValueEncoder {

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        value = .dictionary([:])
        return KeyedEncodingContainer(Container(codingPath: codingPath, encoder: self, path: .empty))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        value = .array([])
        return UnkeyedContainer(codingPath: codingPath, encoder: self, path: .empty)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        value = .bool(false)
        return SingleContainer(codingPath: codingPath, encoder: self, path: .empty)
    }
}
