//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public enum CLTCoreError: LocalizedError {

    case exportConflict
    case valueConversion(value: String, type: String)
    case wrongUsage(String)

    public var errorDescription: String? {
        switch self {
        case .exportConflict: return "Ambiguous export specification. '--csv-exp' and --export-format' cannot be used simultaneously"
        case .valueConversion(let value, let type): return "The value '\(value)' is not convertible to \(type)"
        case .wrongUsage(let description): return description
        }
    }
}
