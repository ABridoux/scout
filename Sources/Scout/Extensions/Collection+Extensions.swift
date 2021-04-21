//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension RandomAccessCollection {

    /// When not empty, return the first element and self without the first element
    func headAndTail() -> (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}

extension Collection {

    /// Unwrap all the elements mapped by the provided function. If one unwrap fails, `nil` is returned
    func unwrapAll<T>(_ transform: (Element) throws -> T?) rethrows -> [T]? {
        var unwrapped: [T] = []

        for element in self {
            if let transformed = try transform(element) {
                unwrapped.append(transformed)
            } else {
                return nil
            }
        }

        return unwrapped
    }

    /// Unwrap all the elements mapped by the provided key path. If one unwrap fails, `nil` is returned
    func unwrapAll<T>(_ keyPath: KeyPath<Element, T?>) -> [T]? {
        unwrapAll { $0[keyPath: keyPath] }
    }
}
