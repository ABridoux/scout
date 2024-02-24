//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Yams
import Foundation

// MARK: - YamlDefault

public extension CodableFormats {

    enum YamlDefault: CodableFormat {

        // MARK: Constants

        public static var dataFormat: DataFormat { .yaml }

        public static var foldedRegexPattern: String {
            #"\#(foldedMark)\s*(?=\n)"# // array
            + #"|\#(foldedKey)\s*:\s*\#(foldedMark)\s*(?=\n)"# // dict
        }

        private static let encoder = YAMLEncoder()
        private static let decoder = YAMLDecoder()

        // MARK: Encode

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value).data(using: .utf8).unwrapOrThrow(.stringToData)
        }

        // MARK: Decode

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }
    }
}
