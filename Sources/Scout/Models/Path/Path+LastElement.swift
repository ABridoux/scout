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

extension Collection where Element == PathElement {

    var lastGroupSample: ExplorerXML.GroupSample? {
        for element in reversed() {
            switch element {
            case .filter: return .filter
            case .slice: return .slice
            default: continue
            }
        }

        return nil
    }
}

extension RandomAccessCollection {

    /// When not empty, return the first element and self without the first element
    func cutHead() -> (head: Element, tail: SubSequence)? {
        guard let head = first else { return nil }
        return (head, dropFirst())
    }
}
