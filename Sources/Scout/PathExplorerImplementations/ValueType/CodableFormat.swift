//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public protocol CodableFormat {

    static var dataFormat: DataFormat { get }

    static func encode<E: Encodable>(_ value: E) throws -> Data
    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

public enum CodableFormats {}

public extension CodableFormats {

    enum Json: CodableFormat {

        public static var dataFormat: DataFormat { .json }

        public static func encode<E: Encodable>(_ value: E) throws -> Data {
            try JSONEncoder().encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
            try JSONDecoder().decode(type, from: data)
        }

    }
}
