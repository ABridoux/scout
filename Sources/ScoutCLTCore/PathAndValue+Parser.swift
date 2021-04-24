//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout
import Parsing

extension PathAndValue {
    enum ValueParsers {}
}

extension PathAndValue.ValueParsers {

    static var keyName: Parser<ValueType> {
        Parsers.string(forbiddenCharacters: "#").enclosed(by: "#").map(ValueType.keyName)
    }

    static var real: Parser<ValueType> {
        Parsers.string(forbiddenCharacters: "~").enclosed(by: "~").map(ValueType.real)
    }

    static var string: Parser<ValueType> {
        Parsers.string(forbiddenCharacters: "/").enclosed(by: "/").map(ValueType.string)
        <|>
        Parsers.string(forbiddenCharacters: "'").enclosed(by: "'").map(ValueType.string)
    }

    static var automatic: Parser<ValueType> {
        Parsers.nonEmptyString.map(ValueType.automatic)
    }

    static var parser: Parser<ValueType> {
        keyName
            <|> real
            <|> string
            <|> automatic
    }
}

infix operator <^>: SequencePrecedence

extension PathAndValue {

    static var parser: Parser<(pathElements: [PathElement], value: ValueType)> {
        curry { path, _, value in (path, value) }
            <^> Path.parser(separator: ".", keyForbiddenCharacters: ["="])
            <*> .character("=")
            <*> ValueParsers.parser
    }
}
