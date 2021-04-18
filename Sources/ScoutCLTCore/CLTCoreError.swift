//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public enum CLTCoreError: LocalizedError {

    case exportConflict

    public var errorDescription: String? {
        switch self {
        case .exportConflict: return "Ambiguous export specification. '--csv' and --export-format' cannot be used simultaneously"
        }
    }
}
