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

    static let forbiddenCharacters: [Character] = ["[", "]", ",", ":", "{", "}"]

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

    static var emptyDictionary: Parser<ValueType> {
        Parsers.string("{}").map { _ in ValueType.dictionary([:]) }
    }

    static var dictionary: Parser<ValueType> {
        (dictionaryElement <* Parsers.character(",").optional)
            .many1
            .parenthesisedCurl
            .map { elements -> ValueType in
                if let duplicate = elements.map(\.key).duplicate() {
                    let dictDescription = elements.map { "\($0.key): \($0.value.description)" }.joined(separator: ", ")
                    let description = "Duplicate key '\(duplicate)' in the dictionary {\(dictDescription)}"
                    return .error(description)
                }
                let dict = Dictionary(uniqueKeysWithValues: elements)
                return .dictionary(dict)
        }
    }

    static var arrayElement: Parser<ValueType> {
        .lazy(parser.surrounded(by: .whiteSpacesOrNewLines))
    }

    static var emptyArray: Parser<ValueType> {
        Parsers.string("[]").map { _ in ValueType.array([]) }
    }

    static var array: Parser<ValueType> {
        (arrayElement <* Parsers.character(",").optional)
            .many1
            .parenthesisedSquare
            .map(ValueType.array)
    }

    static var error: Parser<ValueType> {
        Parser<ValueType> { input in
            guard !input.isEmpty else { return nil }
            let description = "Parsing error in value '\(input)'"
            return (ValueType.error(description), "")
        }
    }

    static var parser: Parser<ValueType> {
        keyName
            <|> real
            <|> string
            <|> automatic
            <|> emptyArray
            <|> emptyDictionary
            <|> array
            <|> dictionary
    }
}

extension PathAndValue.ValueParsers {

    static var zshAutomatic: Parser<ValueType> {
        Parsers.string(forbiddenCharacters: [" ", "]", "}"]).map(ValueType.automatic)
    }

    static var zshArrayElement: Parser<ValueType> {
        real
            <|> string
            <|> zshAutomatic
    }

    static var zshArray: Parser<ValueType> {
        (zshArrayElement <* Parsers.character(" ").optional)
            .many1
            .parenthesisedSquare
            .map(ValueType.array)
    }

    static var zshAssociativeArray: Parser<ValueType> {
        (zshArrayElement <* Parsers.character(" ").optional)
            .many1
            .parenthesisedCurl
            .map { elements -> ValueType in
                guard elements.count.isMultiple(of: 2) else {
                    return .error("Invalid associative array with non even count")
                }
                var dict: [String: ValueType] = [:]
                for index in stride(from: 0, to: elements.count - 1, by: 2) {
                    guard let key = elements[index].string else {
                        return .error("String \(elements[index]) is not a valid key")
                    }
                    let value = elements[index + 1]
                    dict[key] = value
                }
                return .dictionary(dict)
            }
    }

    static var zshGroup: Parser<ValueType> {
        zshArray <|> zshAssociativeArray
    }
}

infix operator <^>: SequencePrecedence

extension PathAndValue {

    static var parser: Parser<(pathElements: [PathElement], value: ValueType)> {
        curry { path, _, value in (path, value) }
            <^> Path.parser(separator: ".", keyForbiddenCharacters: ["="])
            <*> .character("=")
            <*> (ValueParsers.zshGroup <|> ValueParsers.parser <|> ValueParsers.error)
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
