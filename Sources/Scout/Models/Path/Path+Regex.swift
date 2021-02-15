//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path {

    static let defaultSeparator = "."
    private static let countSymbol = PathElement.defaultCountSymbol
    private static let keysListSymbol = PathElement.defaultKeysListSymbol

    private static let forbiddenSeparators: Set<String> = ["[", "]", "(", ")"]
    private static let separatorsToEscape = CharacterSet(charactersIn: "*?+[(){}^$|./")
    private static let escapeToEscape = CharacterSet(charactersIn: "\\")

    static func splitRegexPattern(separator: String = defaultSeparator) -> String {
        var regex = #"\(.+\)"# // anything between brackets is allowed
        regex += #"|\[[0-9\#(countSymbol):-]+\]"# // indexes and count
        regex += #"|\{\#(keysListSymbol)\}"# // keys list
        regex += #"|#(\x5C#|[^#])+#"# // dictionary filter
        regex += #"|[^\#(separator)^\[^\]^\{^\}]+"# // standard key

        return regex
    }

    static func validate(separator: String) throws {
        if forbiddenSeparators.contains(separator) {
            throw PathError.invalidSeparator(separator)
        }
        guard
            let range = separator.rangeOfCharacter(from: separatorsToEscape) ??
                separator.rangeOfCharacter(from: escapeToEscape)
        else {
            return
        }
        guard range.lowerBound > separator.startIndex else {
            throw PathError.invalidSeparator(separator)
        }

        let previousIndex = separator.index(before: range.lowerBound)
        if separator[previousIndex] != "\\" {
            throw PathError.invalidSeparator(separator)
        }
    }
}
