//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Path {

    static func keyParser(separator: String) -> PathParser<PathElement> {
        PathParsers.string(stoppingAt: separator, forbiddenCharacters: "[", "{").map(PathElement.key)
    }

    static var parenthesisedKeyParser: PathParser<PathElement> {
        PathParsers.string(forbiddenCharacters: ")").parenthesised.map(PathElement.key)
    }

    static var indexParser: PathParser<PathElement> {
        PathParsers.signedInteger.parenthesisedSquare.map(PathElement.index)
    }

    static var countParser: PathParser<PathElement> {
        PathParsers.character("#").parenthesisedSquare.map { _ in PathElement.count }
    }

    static var keysListParser: PathParser<PathElement> {
        PathParsers.character("#").parenthesisedCurl.map { _ in PathElement.keysList }
    }

    static var boundsParser: PathParser<Bounds> {
        curry { (lower, _, upper) in Bounds(lower: lower, upper: upper) }
            <^> PathParsers.signedInteger.optional
            <*> .character(":")
            <*> PathParsers.signedInteger.optional
    }

    static var sliceParser: PathParser<PathElement> {
        boundsParser.map(PathElement.slice).parenthesisedSquare
    }

    static var filterParser: PathParser<PathElement> {
        PathParsers.string(stoppingAt: "#").enclosed(by: "#").map(PathElement.filter)
    }

    static func singlePathElementParser(separator: String) -> PathParser<PathElement> {
        filterParser
            <|> sliceParser
            <|> countParser
            <|> keysListParser
            <|> indexParser
            <|> parenthesisedKeyParser
            <|> keyParser(separator: separator)
    }
}

extension Path {

    static func pathElementWithIndexing(separator: String) -> PathParser<[PathElement]> {
        curry { [$0] + $1 } <^> singlePathElementParser(separator: separator) <*> (indexParser <|> sliceParser).many
    }

    static func parser(separator: String) -> PathParser<[PathElement]> {
        (pathElementWithIndexing(separator: separator) <* PathParsers.string(separator).optional)
            .many
            .map { elements in
                elements.flatMap { $0 }
            }
    }
}
