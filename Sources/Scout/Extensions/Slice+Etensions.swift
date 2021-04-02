//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Slice where Base == Path {

    var leftPart: Self {
        base[..<index(before: startIndex)]
    }
}
