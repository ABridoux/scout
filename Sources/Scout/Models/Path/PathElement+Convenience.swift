//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension PathElement {

    /// Placed after an array to slice it with a `Bounds` value
    public static func slice(_ lower: Bounds.Bound, _ upper: Bounds.Bound) -> PathElement {
        .slice(Bounds(lower: lower, upper: upper))
    }

    /// Get all elements (convenience for testing)
    static var sliceAll: PathElement { .slice(.first, .last) }

    /// Get all elements (convenience for testing)
    static var filterAll: PathElement { .filter(".*") }
}
