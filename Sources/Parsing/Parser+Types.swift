//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public typealias Parsers = Parser<String>

public extension Parser {

    static func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
        Parser<Character> { input in
            guard let char = input.first, condition(char) else { return nil }
            return (char, input.dropFirst())
        }
    }

    static func character(_ char: Character) -> Parser<Character> {
        character { $0 == char }
    }

    static var digit: Parser<Character> {
        character { $0.isDecimalDigit }
    }

    static var integer: Parser<Int> {
        digit.many1.map { Int(String($0))! }
    }

    static var whiteSpaceOrNewLine: Parser<Character> {
        character { $0.isNewline || $0.isWhitespace }
    }

    static var whiteSpacesOrNewLines: Parser<String> {
        whiteSpaceOrNewLine.many.map { String($0) }
    }

    /// Match any non empty string
    static var nonEmptyString: Parser<String> {
        Parser<String> { input in
            if input.isEmpty {
                return nil
            } else {
                return (String(input), "")
            }
        }
    }

    /// Integer with an optional +/- prefix
    static var signedInteger: Parser<Int> {
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

    /// Match when the input starts with the provided string
    static func string(_ string: String) -> Parser<String> {
        Parser<String> { input in
            guard input.hasPrefix(string) else { return nil }
            let remainder = input.dropFirst(string.count)
            return (string, remainder)
        }
    }

    /// Match characters until one of the forbidden ones is encountered
    static func string(forbiddenCharacters firstCharacter: Character, _ additionalCharacters: Character...) -> Parser<String> {
        string(forbiddenCharacters: [firstCharacter] + additionalCharacters)
    }

    /// Match characters until one of the forbidden ones is encountered
    static func string(forbiddenCharacters: [Character]) -> Parser<String> {
        Parser<String> { input in
            guard !input.isEmpty else { return nil }
            let forbiddenCharacters = Set(forbiddenCharacters)
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

    /// Match characters until one of the forbidden ones is encountered
    static func string(forbiddenCharacters isForbidden: @escaping (Character) -> Bool) -> Parser<String> {
        Parser<String> { input in
            guard !input.isEmpty else { return nil }
            var remainder = input
            var currentString = ""

            while let char = remainder.first {
                if isForbidden(char) { break }
                currentString += String(char)
                remainder = remainder.dropFirst()
            }

            return currentString.isEmpty ? nil : (currentString, remainder)
        }
    }

    /// Match characters until the last ones equal the forbidden string, or if the character matches one of the forbidden ones
    ///
    /// ### Examples
    /// ```
    /// let parser = PathParsers.string(stoppingAt: "Toto")
    /// let result = parser.run("Hello Toto!")
    /// print(result?.result) // "Hello"
    /// print(result?.remainder) // " Toto!"
    /// ```
    ///
    /// - Parameters:
    ///   - forbiddenString: The string to stop at
    ///   - forbiddenCharacters: Additional forbidden characters that should stop the parsing
    static func string(stoppingAt forbiddenString: String, forbiddenCharacters: [Character]) -> Parser<String> {
        Parser<String> { input in
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

    static func string(stoppingAt forbiddenString: String, forbiddenCharacters: Character...) -> Parser<String> {
        string(stoppingAt: forbiddenString, forbiddenCharacters: forbiddenCharacters)
    }
}

public extension Parser {

    var parenthesised: Parser<R> {
        .character("(") *> self <* .character(")")
    }

    var parenthesisedSquare: Parser<R> {
        .character("[") *> self <* .character("]")
    }

    var parenthesisedCurl: Parser<R> {
        .character("{") *> self <* .character("}")
    }

    var parenthesisedChevrons: Parser<R> {
        .character("<") *> self <* .character(">")
    }

    func enclosed(by character: Character) -> Parser {
        .character(character) *> self <* .character(character)
    }

    func surrounded<A>(by parser: Parser<A>) -> Parser {
        parser *> self <* parser
    }
}

public extension Parser {

    static func lazy<A>(_ parser: @autoclosure @escaping () -> Parser<A>) -> Parser<A> {
        return Parser<A> { parser().parse($0) }
    }
}
