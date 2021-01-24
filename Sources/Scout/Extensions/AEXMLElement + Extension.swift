//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    /// Copy of the element, without the children
    func copy() -> AEXMLElement { AEXMLElement(name: name, value: value, attributes: attributes) }

    /// Name of the first child if one exists. Otherwise the parent key name will be used.
    var childrenName: String { children.first?.name ?? name }

    /// The common name of all the children is one is found
    /// - note: Handles the case where the name is a path leading to the key when using dictionary filters
    var commonChildrenName: String? {
        guard
            let firstChild = children.first,
            let name = firstChild.name.components(separatedBy: GroupSample.keySeparator).last
        else {
            return nil
        }

        for child in children {
            if child.name.components(separatedBy: GroupSample.keySeparator).last != name {
                return nil
            }
        }

        return name
    }
}

extension AEXMLElement {

    enum Group {
        case array, dictionary
    }

    private struct GroupCount {
        var arrays = 0
        var dicitionaries = 0

        var max: Group {
            if arrays > dicitionaries {
                return .array
            }
            return .dictionary // dictionary in case of equality (arbitrary)
        }
    }

    /// Indicates whether the children are most likely to be arrays or dictionaries
    ///
    /// #### Complexity
    /// O(nm) where
    /// - n: Children count
    /// - m: Maximum children's children count
    var bestChildrenGroupFit: Group {
        var groupCounts = GroupCount()

        children.forEach { child in
            if child.children.count > 1, child.commonChildrenName != nil {
                groupCounts.arrays += 1
            } else {
                groupCounts.dicitionaries += 1
            }
        }

        return groupCounts.max
    }
}
