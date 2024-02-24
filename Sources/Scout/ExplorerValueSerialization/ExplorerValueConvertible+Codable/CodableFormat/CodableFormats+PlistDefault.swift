//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - PlistDefault

public extension CodableFormats {

    enum PlistDefault: CodableFormat {

        // MARK: Constants

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

        // MARK: Encode

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value)
        }

        // MARK: Decode

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }
    }
}
