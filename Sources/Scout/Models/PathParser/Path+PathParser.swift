//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Path {
    enum ElementParsers {}
}

extension Path.ElementParsers {

    static func key(separator: String) -> PathParser<PathElement> {
        PathParsers.string(stoppingAt: separator, forbiddenCharacters: "[", "{").map(PathElement.key)
    }

    static var parenthesisedKey: PathParser<PathElement> {
        PathParsers.string(forbiddenCharacters: ")").parenthesised.map(PathElement.key)
    }

    static var index: PathParser<PathElement> {
        PathParsers.signedInteger.parenthesisedSquare.map(PathElement.index)
    }

    static var count: PathParser<PathElement> {
        PathParsers.character("#").parenthesisedSquare.map { _ in PathElement.count }
    }

    static var keysList: PathParser<PathElement> {
        PathParsers.character("#").parenthesisedCurl.map { _ in PathElement.keysList }
    }

    static var bounds: PathParser<Bounds> {
        curry { (lower, _, upper) in Bounds(lower: lower, upper: upper) }
            <^> PathParsers.signedInteger.optional
            <*> .character(":")
            <*> PathParsers.signedInteger.optional
    }

    static var slice: PathParser<PathElement> {
        bounds.map(PathElement.slice).parenthesisedSquare
    }

    static var filter: PathParser<PathElement> {
        PathParsers.string(stoppingAt: "#").enclosed(by: "#").map(PathElement.filter)
    }

    static func singlePathElement(separator: String) -> PathParser<PathElement> {
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

    static func parser(separator: String) -> PathParser<[PathElement]> {
        (ElementParsers.singlePathElement(separator: separator) <* PathParsers.string(separator).optional).many
    }
}
