//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Collection where Element: Hashable {

    /// Find a duplicate in the collection.
    ///
    /// ### Complexity
    /// `O(n)`
    func duplicate() -> Element? {
        var foundElements: Set<Element> = []

        for element in self {
            if foundElements.contains(element) {
                return element
            } else {
                foundElements.insert(element)
            }
        }
        return nil
    }
}

extension Dictionary where Key: Hashable {

    /// Find a duplicate in the collection.
    ///
    /// ### Complexity
    /// `O(n)`
    func duplicateKey() -> Key? {
        var foundElements: Set<Key> = []

        for element in self {
            if foundElements.contains(element.key) {
                return element.key
            } else {
                foundElements.insert(element.key)
            }
        }
        return nil
    }

}
