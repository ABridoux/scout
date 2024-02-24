//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - JsonDefault

public extension CodableFormats {

    enum JsonDefault: CodableFormat {

        // MARK: Constants

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

        // MARK: Encode

        public static func encode<E: Encodable>(_ value: E, rootName: String?) throws -> Data {
            try encoder.encode(value)
        }

        // MARK: Decode

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }
    }
}
