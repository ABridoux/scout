//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - ValueTarget

extension PathsFilter {

    /// Specifies if group (array, dictionary) values, single (string, bool...) values or both should be targeted.
    public enum ValueTarget: String, CaseIterable {

        /// Allows the key with a single or a group value.
        case singleAndGroup

        /// Allows the key with a single value.
        case group

        /// Allows the key with a group (array, dictionary) value.
        case single
    }
}

// MARK: - Computed

extension PathsFilter.ValueTarget {

    /// Allows group values (array, dictionaries)?
    var groupAllowed: Bool { [.singleAndGroup, .group].contains(self) }

    /// Allow single values (string, bool...)?
    var singleAllowed: Bool { [.singleAndGroup, .single].contains(self) }
}
