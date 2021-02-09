//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public extension Collection where Element == Path {

    /// Sort by key or index when found at the same position
    func sortedByKeysAndIndexes() -> [Path] {
        sorted { (lhs, rhs) in

            var lhsIterator = lhs.makeIterator()
            var rhsIterator = rhs.makeIterator()

            while let lhsElement = lhsIterator.next(), let rhsElement = rhsIterator.next() {
                switch (lhsElement, rhsElement) {

                case (.key(let lhsLabel), .key(let rhsLabel)):
                    if lhsLabel != rhsLabel {
                        return lhsLabel < rhsLabel
                    }

                case (.index(let lhsIndex), .index(let rhsIndex)):
                    if lhsIndex != rhsIndex {
                        return lhsIndex < rhsIndex
                    }

                default:
                    return true
                }
            }

            return lhs.count < rhs.count // put the shorter path before
        }
    }
}
