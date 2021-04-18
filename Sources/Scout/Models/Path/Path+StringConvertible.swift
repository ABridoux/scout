//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public extension Collection where Element == PathElement {

    /// Prints all the elements in the path, with the default separator
    /// #### Complexity
    /// O(n) where `n`: element's count
    var description: String {
        var description = reduce(into: "", newDescription)

        if description.hasSuffix(Path.defaultSeparator) {
            description.removeLast()
        }

        return description
    }

    var debugDescription: String { description }

    private func newDescription(from description: inout String, with element: PathElement) {

        switch element {

        case .index, .count, .slice, .keysList:
            // remove the point added automatically to a path element
            if description.hasSuffix(Path.defaultSeparator) {
                description.removeLast()
            }
            description.append(element.description)

        case .filter(let pattern):
            description.append("#\(pattern)#")

        case .key:
            description.append(element.description)
        }

        description.append(Path.defaultSeparator)
    }
}

extension Path: CustomStringConvertible, CustomDebugStringConvertible {}
extension Slice: CustomStringConvertible, CustomDebugStringConvertible where Base == Path {}
