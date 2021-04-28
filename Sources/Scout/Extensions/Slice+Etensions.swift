//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Slice where Base == Path {

    /// The part from base start to the beginning of the slice
    var leftPart: Self {
        base[..<index(before: startIndex)]
    }
}
