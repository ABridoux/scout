//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Parsing

extension Path {
    enum ElementParsers {}
}

extension Path.ElementParsers {

    static func key(separator: String) -> Parser<PathElement> {
        Parsers.string(stoppingAt: separator, forbiddenCharacters: "[", "{").map(PathElement.key)
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

    static func singlePathElement(separator: String) -> Parser<PathElement> {
        filter
            <|> slice
            <|> count
            <|> keysList
            <|> index
            <|> parenthesisedKey
            <|> key(separator: separator)
    }
}

extension Path {

    static func parser(separator: String) -> Parser<[PathElement]> {
        (ElementParsers.singlePathElement(separator: separator) <* Parsers.string(separator).optional).many
    }
}
