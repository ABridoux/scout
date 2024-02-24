//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Parsing

// MARK: - ElementParsers

extension Path {
    enum ElementParsers {}
}

// MARK: - Elements

extension Path.ElementParsers {

    static func key(separator: String, forbiddenCharacters: [Character]) -> Parser<PathElement> {
        Parsers.string(
            stoppingAt: separator,
            forbiddenCharacters: forbiddenCharacters + ["[", "{"]
        ).map(PathElement.key)
    }

    static var parenthesisedKey: Parser<PathElement> {
        Parsers.string(forbiddenCharacters: ")").parenthesised.map(PathElement.key)
    }

    static var index: Parser<PathElement> {
        Parsers.signedInteger.parenthesisedSquare.map(PathElement.index)
    }

    static var count: Parser<PathElement> {
        Parsers.character("#").parenthesisedSquare.map { _ in PathElement.count }
    }

    static var keysList: Parser<PathElement> {
        Parsers.character("#").parenthesisedCurl.map { _ in PathElement.keysList }
    }

    static var bounds: Parser<Bounds> {
        curry { (lower, _, upper) in Bounds(lower: lower, upper: upper) }
            <^> Parsers.signedInteger.optional
            <*> .character(":")
            <*> Parsers.signedInteger.optional
    }

    static var slice: Parser<PathElement> {
        bounds.map(PathElement.slice).parenthesisedSquare
    }

    static var filter: Parser<PathElement> {
        Parsers.string(stoppingAt: "#").enclosed(by: "#").map(PathElement.filter)
    }

    static func singlePathElement(separator: String, forbiddenCharacters: [Character]) -> Parser<PathElement> {
        filter
            <|> slice
            <|> count
            <|> keysList
            <|> index
            <|> parenthesisedKey
            <|> key(separator: separator, forbiddenCharacters: forbiddenCharacters)
    }
}

// MARK: - Public

extension Path {

    /// Parse a `Path` from a provided `String`
    /// - Parameters:
    ///   - separator: Separator between keys elements
    ///   - keyForbiddenCharacters: Optionally prevent characters to be parsed in a key name
    public static func parser(separator: String, keyForbiddenCharacters: [Character] = []) -> Parser<[PathElement]> {
        (ElementParsers.singlePathElement(separator: separator, forbiddenCharacters: keyForbiddenCharacters)
            <* Parsers.string(separator).optional
        ).many
    }
}
