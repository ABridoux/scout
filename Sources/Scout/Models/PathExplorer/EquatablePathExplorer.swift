//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// Internal protocol to declare how to test equality to another PathExplorer of the same type without publicly declare conformance to  `Equatable`
protocol EquatablePathExplorer: PathExplorer {

    /// `true` when self is equal to the provided other element.
    /// 
    /// ### Complexity
    /// Most often `O(n)` where `n` is the children count.
    func isEqual(to other: Self) -> Bool
}

extension EquatablePathExplorer where Self: Equatable {

    func isEqual(to other: Self) -> Bool { self == other }
}
