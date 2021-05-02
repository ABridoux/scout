//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Yams

public protocol CodableFormat {

    static var dataFormat: DataFormat { get }

    /// Regex used to find folded marks in the description of a folded explorer
    static var foldedRegexPattern: String { get }

    static func encode<E: Encodable>(_ value: E, rootName: String?) throws -> Data
    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

public extension CodableFormat {

    static func encode<E: Encodable>(_ value: E) throws -> Data {
        try encode(value, rootName: nil)
    }
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

        private static let encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return encoder
        }()

        private static let decoder: JSONDecoder = JSONDecoder()

        public static func encode<E: Encodable>(_ value: E, rootName: String?) throws -> Data {
            try encoder.encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }
    }
}

extension CodableFormats {

    public enum JsonDateIso8601: CodableFormat {

        public static let dataFormat: DataFormat = .json
        public static var foldedRegexPattern: String { JsonDefault.foldedRegexPattern }

        private static let decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()

        private static let encoder: JSONEncoder = {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            return encoder
        }()

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value)
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

        private static let encoder: PropertyListEncoder = {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            return encoder
        }()

        private static let decoder: PropertyListDecoder = PropertyListDecoder()

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
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

        private static let encoder = YAMLEncoder()
        private static let decoder = YAMLDecoder()

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value).data(using: .utf8).unwrapOrThrow(.stringToData)
        }

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }
    }
}
