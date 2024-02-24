//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - CodableFormat

public protocol CodableFormat {

    // MARK: Properties

    static var dataFormat: DataFormat { get }

    /// Regex used to find folded marks in the description of a folded explorer
    static var foldedRegexPattern: String { get }

    // MARK: Encode

    static func encode<E: Encodable>(_ value: E, rootName: String?) throws -> Data

    // MARK: Decode

    static func decode<D: Decodable>(_ type: D.Type, from data: Data) throws -> D
}

// MARK: Encode

public extension CodableFormat {

    static func encode<E: Encodable>(_ value: E) throws -> Data {
        try encode(value, rootName: nil)
    }
}

// MARK: - Constants

extension CodableFormat {

    static var foldedKey: String { Folding.foldedKey }
    static var foldedMark: String { Folding.foldedMark }
}
