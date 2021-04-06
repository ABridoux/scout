//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Yams
import XMLCoder

public protocol CodableFormat {

    static var dataFormat: DataFormat { get }

    static func encode<E: Encodable>(_ value: E) throws -> Data
    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

public enum CodableFormats {}

public extension CodableFormats {

    enum JsonDefault: CodableFormat {

        public static var dataFormat: DataFormat { .json }

        public static func encode<E: Encodable>(_ value: E) throws -> Data {
            try JSONEncoder().encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try JSONDecoder().decode(type, from: data)
        }
    }
}

public extension CodableFormats {

    enum PlistDefault: CodableFormat {

        public static var dataFormat: DataFormat { .plist }

        public static func encode<E>(_ value: E) throws -> Data where E : Encodable {
            try PropertyListEncoder().encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
            try PropertyListDecoder().decode(type, from: data)
        }
    }
}

public extension CodableFormats {

    enum YamlDefault: CodableFormat {

        public static var dataFormat: DataFormat { .yaml }

        public static func encode<E>(_ value: E) throws -> Data where E : Encodable {
            try YAMLEncoder().encode(value).data(using: .utf8).unwrapOrThrow(.stringToData)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
            try YAMLDecoder().decode(type, from: data)
        }
    }
}

public extension CodableFormats {

    enum XmlDefault: CodableFormat {

        public static var dataFormat: DataFormat { .xml }

        public static func encode<E>(_ value: E) throws -> Data where E : Encodable {
            try XMLEncoder().encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
            try XMLDecoder().decode(type, from: data)
        }
    }
}
