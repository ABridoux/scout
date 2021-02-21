//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser

extension DocCommand {
}

enum AdvancedDocumentation {

    enum Topic: String, ExpressibleByArgument {
        case predicates

        var doc: String {
            switch self {
            case .predicates: return Predicates.text
            }
        }
    }
}
