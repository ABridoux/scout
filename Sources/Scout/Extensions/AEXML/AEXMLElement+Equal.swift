//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    func isEqual(to other: AEXMLElement) -> Bool {

        if children.count != other.children.count {
            return false
        }

        if children.isEmpty, other.children.isEmpty {
            return attributes == other.attributes
                && (name == other.name || name == "root" || other.name == "root") // root names are not always the same
                && value == other.value
        }

        var sortedChildren: [AEXMLElement]
        var otherSortedChildren: [AEXMLElement]

        if commonChildrenName != nil { // array
            // sort by value
            sortedChildren = children.sorted { $0.string < $1.string }
            otherSortedChildren = other.children.sorted { $0.string < $1.string }
        } else {
            // sort by key
            sortedChildren = children.sorted { $0.name < $1.name }
            otherSortedChildren = other.children.sorted { $0.name < $1.name }
        }

        return zip(sortedChildren, otherSortedChildren).first { !$0.isEqual(to: $1) } == nil
    }
}