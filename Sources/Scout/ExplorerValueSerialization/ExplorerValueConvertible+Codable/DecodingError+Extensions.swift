//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension DecodingError {

    static func typeMismatch<T>(_ type: T.Type, codingPath: [CodingKey]) -> DecodingError {
        DecodingError.typeMismatch(
            T.self,
            DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }
}
