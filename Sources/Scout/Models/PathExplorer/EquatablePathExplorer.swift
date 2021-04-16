//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

protocol EquatablePathExplorer: PathExplorer {

    /// `true` when self is equal to the provided other element.
    /// #### Complexity
    /// Most often `O(n)` where `n` is the children count.
    func isEqual(to other: Self) -> Bool
}

extension EquatablePathExplorer where Self: Equatable {

    func isEqual(to other: Self) -> Bool { self == other }
}
