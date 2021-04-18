//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

typealias PathParsers = PathParser<String>

extension PathParser {

    static func character(matching condition: @escaping (Character) -> Bool) -> PathParser<Character> {
        PathParser<Character> { input in
            guard let char  = input.first, condition(char) else { return nil }
            return (char, input.dropFirst())
        }
    }

    static func character(_ char: Character) -> PathParser<Character> {
        character { $0 == char }
    }

    static var digit: PathParser<Character> {
        character { $0.isDecimalDigit }
    }

    static var integer: PathParser<Int> {
        digit.many1.map { Int(String($0))! }
    }

    /// Integer with an optional +/- prefix
    static var signedInteger: PathParser<Int> {
        curry { (sign, int) in
            switch sign {
            case "+", nil: return int
            case "-": return -int
            default:
                assertionFailure("This case is impossible")
                return int
            }
        }
        <^> (.character("+") <|> .character("-")).optional
        <*> integer
    }

    static func string(_ string: String) -> PathParser<String> {
        PathParser<String> { input in
            guard input.hasPrefix(string) else { return nil }
            let remainder = input.dropFirst(string.count)
            return (string, remainder)
        }
    }

    static func string(forbiddenCharacters firstCharacter: Character, _ additionalCharacters: Character...) -> PathParser<String> {
        PathParser<String> { input in
            guard !input.isEmpty else { return nil }
            let forbiddenCharacters = Set([firstCharacter] + additionalCharacters)
            var remainder = input
            var currentString = ""

            while let char = remainder.first {
                if forbiddenCharacters.contains(char) { break }
                currentString += String(char)
                remainder = remainder.dropFirst()
            }

            return currentString.isEmpty ? nil : (currentString, remainder)
        }
    }

    static func string(stoppingAt forbiddenString: String, forbiddenCharacters: Character...) -> PathParser<String> {
        PathParser<String> { input in
            guard !input.isEmpty else { return nil }

            let forbiddenCharacters = Set(forbiddenCharacters)
            var currentString = ""
            var remainder = input
            var matchingForbiddenString = ""

            while let char = remainder.first {
                if forbiddenCharacters.contains(char) { break }

                let stringChar = String(char)

                if forbiddenString == matchingForbiddenString { break }

                if forbiddenString.hasPrefix(matchingForbiddenString + stringChar) {
                    matchingForbiddenString += stringChar
                } else {
                    currentString += matchingForbiddenString + stringChar
                    matchingForbiddenString.removeAll()
                }

                remainder = remainder.dropFirst()
            }

            if currentString.isEmpty { return nil }
            return (currentString, matchingForbiddenString + remainder)
        }
    }

    var parenthesised: PathParser<R> {
        .character("(") *> self <* .character(")")
    }

    var parenthesisedSquare: PathParser<R> {
        .character("[") *> self <* .character("]")
    }

    var parenthesisedCurl: PathParser<R> {
        .character("{") *> self <* .character("}")
    }

    func enclosed(by character: Character) -> PathParser<R> {
        .character(character) *> self <* .character(character)
    }
}
