//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public extension Path {

    /// Retrieve all the index elements
    var compactMapIndexes: [Int] {
        compactMap(\.index)
    }

    /// Retrieve all the key elements
    var compactMapKeys: [String] {
        compactMap(\.key)
    }

    /// Retrieve all the slices bounds elements
    var compactMapSlices: [Bounds] {
        compactMap {
            if case let .slice(bounds) = $0 {
                return bounds
            }
            return nil
        }
    }

    /// Retrieve all the filter elements
    var compactMapFilter: [String] {
        compactMap {
            if case let .filter(pattern) = $0 {
                return pattern
            }
            return nil
        }
    }
}
