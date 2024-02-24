//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - typeMismatch

extension DecodingError {

    static func typeMismatch<T>(_ type: T.Type, codingPath: [CodingKey]) -> DecodingError {
        DecodingError.typeMismatch(
            T.self,
            DecodingError.Context(codingPath: codingPath, debugDescription: ""))
    }
}
