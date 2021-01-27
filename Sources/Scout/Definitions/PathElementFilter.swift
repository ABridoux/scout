//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum PathElementFilter {
    case key(regex: NSRegularExpression)
}

extension PathElementFilter {

    /// Specify if group (array, dictionary) values, single values or both paths should be targeted
    public enum ValueType: String, CaseIterable {
        /// Allows the key with a single or a group value
        case singleAndGroup
        /// Allows the key with a single value
        case group
        /// Allows the key with a group (array, dictionary) value
        case single

        var groupAllowed: Bool { [.singleAndGroup, .group].contains(self) }
        var singleAllowed: Bool { [.singleAndGroup, .single].contains(self) }
    }
}
