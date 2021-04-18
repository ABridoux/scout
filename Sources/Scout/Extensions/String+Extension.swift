//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension String {

    /// The NSRange of the full string
    var nsRange: NSRange { NSRange(location: 0, length: count) }

    /// ### Complexity
    /// O(k), where k is the absolute value of distance.
    subscript(_ range: NSRange) -> Substring {
        let sliceStartIndex = index(startIndex, offsetBy: range.location)
        let sliceEndIndex = index(startIndex, offsetBy: range.upperBound - 1)

        return self[sliceStartIndex...sliceEndIndex]
    }

    func isEnclosed(by string: String) -> Bool { hasPrefix(string) && hasSuffix(string) }

    /// Remove the enclosing brackets '(' ')' if found
    func removingEnclosingBrackets() -> String {
        if hasPrefix("("), hasSuffix(")") {
            return String(self[index(after: startIndex)..<index(before: endIndex)])
        }
        return self
    }

    /// Escape the given string for a CSV export
    func escapingCSV(_ string: String) -> String {
        if contains(string) {
            return #""\#(self)""#
        } else {
            return self
        }
    }
}
