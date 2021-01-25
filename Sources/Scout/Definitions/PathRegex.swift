//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum PathFilter {

    case key(regex: NSRegularExpression, valueType: ValueType)
}

extension PathFilter {

    /// Key target with a default `Value.Type.singleAndGroup`
    static func key(regex: NSRegularExpression) -> PathFilter {
        .key(regex: regex, valueType: .singleAndGroup)
    }
}

extension PathFilter {

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
