//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path {

    public var lastKeyElementName: String? {
        let lastKey = last { (element) -> Bool in
            if case .key = element { return true }
            return false
        }
        guard case let .key(name) = lastKey else { return nil }
        return name
    }

    /// Last key component matching the regular expression
    public func lastKeyComponent(matches regularExpression: NSRegularExpression) -> Bool {
        let lastKey = last { (element) -> Bool in
            if case .key = element {
                return true
            }
            return false
        }
        guard case let .key(name) = lastKey else { return false }

        return regularExpression.validate(name)
    }
}
