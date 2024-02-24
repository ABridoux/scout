//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - PathError

enum PathError {

    case invalidStringPath(_ string: String)
    case invalidSeparator(String)
    case invalidRegex(pattern: String)
}

// MARK: - LocalizedError

extension PathError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidStringPath(let string): return "The part '\(string)' of the path is invalid"
        case .invalidSeparator(let separator): return "The separator \(separator) is not forbidden or must be escaped"
        case .invalidRegex(let pattern): return "The regular expression '\(pattern)' to split the path string is not valid."
        }
    }
}
