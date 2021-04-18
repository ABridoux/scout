//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension RandomAccessCollection {

    /// When not empty, return the first element and self without the first element
    func headAndTail() -> (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}
