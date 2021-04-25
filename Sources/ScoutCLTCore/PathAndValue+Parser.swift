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

    static let forbiddenCharacters: [Character] = ["[", "]", ",", ":"]

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
        Parsers.string(forbiddenCharacters: forbiddenCharacters)
            .map(ValueType.automatic)
    }

    static var dictionaryKey: Parser<String> {
        Parsers.string(stoppingAt: "'", forbiddenCharacters: ["'"])
            .enclosed(by: "'").surrounded(by: .whiteSpacesOrNewLines)
        <|>
            Parsers.string(stoppingAt: ":", forbiddenCharacters: forbiddenCharacters)
            .trimming(in: .whitespacesAndNewlines)
    }

    static var dictionaryElement: Parser<(key: String, value: ValueType)> {
        curry { key, _, value in (key, value) }
            <^> dictionaryKey
            <*> .character(":")
            <*> .lazy(parser.surrounded(by: .whiteSpacesOrNewLines))
    }

    static var dictionary: Parser<ValueType> {
        (dictionaryElement <* Parsers.character(",").optional)
            .many1
            .parenthesisedSquare
            .map { elements -> ValueType in
                var keys: Set<String> = []
                
                for element in elements {

                    if keys.contains(element.key) {
                        let dictDescription = elements.map { "\($0.key): \($0.value.description)" }.joined(separator: ", ")
                        let description = "Duplicate key '\(element.key)' in the dictionary [\(dictDescription)]"
                        return .error(description)
                    } else {
                        keys.insert(element.key)
                    }
                }

                let dict = Dictionary(uniqueKeysWithValues: elements)
                return .dictionary(dict)
        }
    }

    static var arrayElement: Parser<ValueType> {
        .lazy(parser.surrounded(by: .whiteSpacesOrNewLines))
    }

    static var array: Parser<ValueType> {
        (arrayElement <* Parsers.character(",").optional)
            .many1
            .parenthesisedSquare
            .map { .array($0) }
    }

    static var error: Parser<ValueType> {
        Parser<ValueType> { input in
            guard !input.isEmpty else { return nil }
            let description = "Parsing error in value '\(input)'"
            return (ValueType.error(description), "")
        }
    }

    static var parser: Parser<ValueType> {
        dictionary
            <|> array
            <|> keyName
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
            <*> (ValueParsers.parser <|> ValueParsers.error)
    }
}

extension ValueType: CustomStringConvertible {

    public var description: String {
        switch self {
        case .automatic(let string): return string
        case .keyName(let keyName): return "#\(keyName)#"
        case .real(let string): return "~\(string)~"
        case .string(let string): return "'\(string)'"

        case .dictionary(let dict):
            let keysAndValues = dict.map { "\($0.key): \($0.value.description)" }.joined(separator: ", ")
            return "[\(keysAndValues)]"

        case .array(let array):
            let values = array.map { $0.description }.joined(separator: ", ")
            return "[\(values)]"

        case .error(let description): return "Error: \(description)"
        }
    }
}
