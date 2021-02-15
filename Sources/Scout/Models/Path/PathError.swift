//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

enum PathError: LocalizedError {
    case invalidSeparator(String)
    case invalidRegex(pattern: String)

    var errorDescription: String? {
        switch self {
        case .invalidSeparator(let separator): return "The separator \(separator) is not fobidden or must be escaped"
        case .invalidRegex(let pattern): return "The regular expression '\(pattern)' to split the path string is not valid."
        }
    }
}
