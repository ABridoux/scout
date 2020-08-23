//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser

enum ColorFlag: String, EnumerableFlag {
    case color
    case noColor
    case nc

    var colorise: Bool {
        switch self {
        case .color: return true
        default: return false
        }
    }
}
