//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Parse a string to an array of `PathElement`s
///
/// - note: Inspired from [functional Swift](https://www.objc.io/books/functional-swift/)
/// *Parser Combinators* chapter
struct PathParser<R> {
    let parse: (Substring) -> (R, Substring)?
}

extension PathParser {

    func run(_ string: String) -> (result: R, remainder: String)? {
        guard let (result, remainder) = parse(Substring(string)) else { return nil }
        return (result, String(remainder))
    }
}
