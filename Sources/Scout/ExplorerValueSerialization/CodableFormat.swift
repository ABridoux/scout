//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Yams
import XMLCoder

public protocol CodableFormat {

    static var dataFormat: DataFormat { get }

    /// Regex used to find folded marks in the description of a folded explorer
    static var foldedRegexPattern: String { get }

    static func encode<E: Encodable>(_ value: E) throws -> Data
    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

private extension CodableFormat {

    static var foldedKey: String { Folding.foldedKey }
    static var foldedMark: String { Folding.foldedMark }
}

public enum CodableFormats {}

public extension CodableFormats {

    enum JsonDefault: CodableFormat {

        public static var dataFormat: DataFormat { .json }
        public static var foldedRegexPattern: String {
            #"(?<=\[)\s*"\#(foldedMark)"\s*(?=\])"# // array
            + #"|(?<=\{)\s*"\#(foldedKey)"\s*:\s*"\#(foldedMark)"\s*(?=\})"# // dict
        }

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

        public static var foldedRegexPattern: String {
            #"(?<=<array>)\s*<string>\#(foldedMark)</string>\s*(?=</array>)"# // array
            + #"|(?<=<dict>)\s*<key>\#(foldedKey)</key>\s*<string>\#(foldedMark)</string>\s*(?=</dict>)"# // dict
        }

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

        public static var foldedRegexPattern: String {
            #"\#(foldedMark)\s*(?=\n)"# // array
            + #"|\#(foldedKey)\s*:\s*\#(foldedMark)\s*(?=\n)"# // dict
        }

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
        public static let foldedRegexPattern = #"(?<=>)\s*<\#(foldedKey)>\#(foldedMark)</\#(foldedKey)>\s*(?=<)"#

        public static func encode<E>(_ value: E) throws -> Data where E : Encodable {
            try XMLEncoder().encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D : Decodable {
            try XMLDecoder().decode(type, from: data)
        }
    }
}
