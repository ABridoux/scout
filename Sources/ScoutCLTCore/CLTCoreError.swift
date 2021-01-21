//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum CLTCoreError: LocalizedError {

    case exportConflict

    public var errorDescription: String? {
        switch self {
        case .exportConflict: return "Ambiguous export specification. '--csv' and --export-fromat' cannot be use simultaneously"
        }
    }
}
