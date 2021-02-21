//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path: CustomStringConvertible, CustomDebugStringConvertible {

    /// Prints all the elements in the path, with the default separator
    /// #### Complexity
    /// O(n) with `n` number of elements in the path
    public var description: String { computeDescription() }

    public var debugDescription: String { description }

    func computeDescription(ignore: ((PathElement) -> Bool)? = nil) -> String {
        var description = ""

        forEach { element in
            if let ignore = ignore, ignore(element) { return }

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

        // remove the last point if any
        if description.hasSuffix(Self.defaultSeparator) {
            description.removeLast()
        }

        return description
    }
}
