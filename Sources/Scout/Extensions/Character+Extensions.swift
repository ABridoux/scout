//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Character {

    var isDecimalDigit: Bool {
        let zero: Character = "0"
        let nine: Character = "9"
        return (zero...nine).contains(self)
    }
}
