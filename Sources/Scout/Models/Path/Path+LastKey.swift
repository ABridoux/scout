//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path {

    public var lastKeyElementName: String? {
        reversed().first {
            guard case .key = $0 else { return false }
            return true
        }?.key
    }

    /// Last key component matching the regular expression
    public func lastKeyComponent(matches regularExpression: NSRegularExpression) -> Bool {
        guard let key = lastKeyElementName else { return false }
        return regularExpression.validate(key)
    }
}
