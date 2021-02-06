//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerXML {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        var explorer = PathExplorerXML(element: element, path: .empty)

        if let path = initialPath {
            try path.forEach { (element) in
                switch element {
                case .count, .keysList:
                    throw PathExplorerError.wrongElement(element: element, command: "paths")

                case .filter, .slice, .index, .key:
                    explorer = try explorer.get(element: element, negativeIndexEnabled: true, detailedName: false)
                }
            }
        }
        var paths = [Path]()
        try explorer.collectKeysPaths(in: &paths, filter: filter)

        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    func collectKeysPaths(in paths: inout [Path], filter: PathsFilter) throws {

        if filter.singleAllowed, let value = element.value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty {
            var isParentArrayAndNameValid = false
            if let parent = element.parent {
                // allow children of an array when the paren name is a match
                isParentArrayAndNameValid = !parent.differentiableChildren && filter.validate(key: parent.name)
            }

            if (filter.validate(key: element.name) || isParentArrayAndNameValid), try filter.validate(value: value) {
                paths.append(readingPath)
            }
        }

        try element.children.enumerated().forEach { (index, child) in
            let newElement: PathElement = element.differentiableChildren ? .key(child.name) : .index(index)

            if child.children.isEmpty {
                let explorer = PathExplorerXML(element: child, path: readingPath.appending(newElement))
                try explorer.collectKeysPaths(in: &paths, filter: filter)
            } else {
                if filter.groupAllowed, filter.validate(key: child.name) {
                    paths.append(readingPath.appending(newElement))
                }
                let explorer = PathExplorerXML(element: child, path: readingPath.appending(newElement))
                try explorer.collectKeysPaths(in: &paths, filter: filter)
            }
        }
    }
}
