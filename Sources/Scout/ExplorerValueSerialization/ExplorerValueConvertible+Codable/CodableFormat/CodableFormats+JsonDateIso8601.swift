//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - JsonDateIso8601

extension CodableFormats {

    public enum JsonDateIso8601: CodableFormat {

        // MARK: Constants

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

        // MARK: Encode

        public static func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
            try decoder.decode(type, from: data)
        }

        // MARK: Decode

        public static func encode<E>(_ value: E, rootName: String?) throws -> Data where E: Encodable {
            try encoder.encode(value)
        }
    }
}
