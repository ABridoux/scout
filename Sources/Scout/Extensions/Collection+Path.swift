//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public extension Collection where Element == PathElement {

    /// Compare key or index when found at the same position
    func comparedByKeyAndIndexes(with otherPath: Path) -> Bool {
        var lhsIterator = makeIterator()
        var rhsIterator = otherPath.makeIterator()

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

        return count < otherPath.count // put the shorter path before
    }
}

public extension Collection where Element == Path {

    /// Sort by key or index when found at the same position
    func sortedByKeysAndIndexes() -> [Path] {
        sorted { (lhs, rhs) in lhs.comparedByKeyAndIndexes(with: rhs) }
    }
}
