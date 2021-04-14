//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathElement {

    public static func slice(_ lower: Bounds.Bound, _ upper: Bounds.Bound) -> PathElement {
        .slice(Bounds(lower: lower, upper: upper))
    }

    /// Get all elements (convenience for testing)
    static var sliceAll: PathElement { .slice(.first, .last) }

    /// Get all elements (convenience for testing)
    static var filterAll: PathElement { .filter(".*") }
}
