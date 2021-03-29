//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path: CustomStringConvertible, CustomDebugStringConvertible {

    /// Prints all the elements in the path, with the default separator
    /// #### Complexity
    /// O(n) where `n`: element's count
    public var description: String {
        var description = reduce(into: "", newDescription)

        if description.hasSuffix(Self.defaultSeparator) {
            description.removeLast()
        }

        return description
    }

    /// Description of the reversed path
    /// ### Complexity
    /// O(n) where `n`: element's count
    public var reversedDescription: String {
        var description = reversed().reduce(into: "", newDescription)

        if description.hasSuffix(Self.defaultSeparator) {
            description.removeLast()
        }

        return description
    }

    public var debugDescription: String { description }

    private func newDescription(from description: inout String, with element: PathElement) {

        switch element {

        case .index, .count, .slice, .keysList:
            // remove the point added automatically to a path element
            if description.hasSuffix(Self.defaultSeparator) {
                description.removeLast()
            }
            description.append(element.description)

        case .filter(let pattern):
            description.append("#\(pattern)#")

        case .key:
            description.append(element.description)
        }

        description.append(Self.defaultSeparator)
    }
}
