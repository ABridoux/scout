//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension NSRegularExpression {

    convenience init(with pattern: String) throws {
        do {
            try self.init(pattern: pattern)
        } catch {
            throw ExplorerError.wrong(regexPattern: pattern)
        }
    }

    /// Validate a string if the first match found by the regex is the overall string
    func validate(_ string: String) -> Bool {
        guard
            let firstMatch = firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)),
            firstMatch.range.length >= 0
        else {
            return false
        }

        if firstMatch.range.length == 0 {
            if string.isEmpty {
                return true
            } else {
                return false
            }
        }

        return string[firstMatch.range] == string
    }
}
