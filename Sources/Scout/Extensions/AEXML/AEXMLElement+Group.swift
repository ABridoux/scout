//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    /// Array or dictionary value type
    enum GroupValue: String {
        case array, dictionary
    }

    private struct GroupCount {
        var arrays = 0
        var dictionaries = 0

        var max: GroupValue {
            if arrays > dictionaries {
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
    var bestChildrenGroupFit: GroupValue {
        var groupCounts = GroupCount()

        children.forEach { child in
            if child.children.count > 1, child.commonChildrenName != nil {
                groupCounts.arrays += 1
            } else {
                groupCounts.dictionaries += 1
            }
        }

        return groupCounts.max
    }
}
