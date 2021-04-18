//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

enum RuntimeError: LocalizedError {
    case invalidData(String)
    case noValueAt(path: String)
    case unknownFormat(String)
    case completionScriptInstallation(description: String)
    case invalidRegex(String)
    case invalidArgumentsCombination(description: String)
    case valueConversion(value: String, type: String)

    var errorDescription: String? {
        switch self {
        case .invalidData(let description): return description
        case .noValueAt(let path): return "No value at '\(path)'"
        case .unknownFormat(let description): return description
        case .completionScriptInstallation(let description): return "Error while installing the completion script. \(description)"
        case .invalidRegex(let pattern): return "The regular expression  '\(pattern)' is invalid"
        case .invalidArgumentsCombination(let description): return description
        case .valueConversion(let value, let type): return "The value \(value) is not convertible to \(type)"
        }
    }
}
