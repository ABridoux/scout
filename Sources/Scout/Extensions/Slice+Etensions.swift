//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Slice where Base == Path {

    /// The part from base start to the beginning of the slice
    var leftPart: Self {
        base[..<index(before: startIndex)]
    }
}
