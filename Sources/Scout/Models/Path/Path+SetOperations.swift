//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public extension Collection where SubSequence == Slice<Path> {

    func commonPrefix(with otherPath: Self) -> Slice<Path> {
        var iterator = makeIterator()
        var otherIterator = otherPath.makeIterator()
        var lastIndex = 0

        while let element = iterator.next(), let otherElement = otherIterator.next(), element == otherElement {
            lastIndex += 1
        }

        return self[0..<lastIndex]
    }
}
