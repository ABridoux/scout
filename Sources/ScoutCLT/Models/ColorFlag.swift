//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser

enum ColorFlag: String, EnumerableFlag {

    /// Specify to colorise the output. Prevented if the program is piped.
    case color

    /// Force the colorisation whether the program is piped or not
    case forceColor

    /// Specify to not colorise the output
    case noColor

    /// Specify to not colorise the output
    case nc

    var colorise: Bool {
        switch self {
        case .color, .forceColor: return true
        case .noColor, .nc: return false
        }
    }
}
