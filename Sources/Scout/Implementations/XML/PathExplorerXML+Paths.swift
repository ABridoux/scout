//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerXML {

    public func listPaths(startingAt initialPath: Path?, for filter: PathElementFilter?, valueType: PathElementFilter.ValueType) throws -> [Path] {
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

        switch filter {
        case .key(let regex): explorer.collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: valueType)
        case nil: explorer.collectKeysPaths(in: &paths, valueType: valueType)
        }

        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    func collectKeysPaths(in paths: inout [Path], valueType: PathElementFilter.ValueType) {

        if valueType.singleAllowed,
           let value = element.value?.trimmingCharacters(in: .whitespacesAndNewlines),
           !value.isEmpty {
            paths.append(readingPath)
        }

        element.children.enumerated().forEach { (index, child) in
            let newElement: PathElement = element.differentiableChildren ? .key(child.name) : .index(index)

            if child.children.isEmpty {
                if valueType.singleAllowed {
                    paths.append(readingPath.appending(newElement))
                }
            } else {
                if valueType.groupAllowed {
                    paths.append(readingPath.appending(newElement))
                }
                let explorer = PathExplorerXML(element: child, path: readingPath.appending(newElement))
                explorer.collectKeysPaths(in: &paths, valueType: valueType)
            }
        }
    }

    func collectKeysPaths(in paths: inout [Path], whereKeyMatches regularExpression: NSRegularExpression, valueType: PathElementFilter.ValueType) {

        if valueType.singleAllowed,
           let value = element.value?.trimmingCharacters(in: .whitespacesAndNewlines),
           !value.isEmpty, regularExpression.validate(element.name) {
            paths.append(readingPath)
        }

        let differentiableChildren = element.differentiableChildren

        element.children.enumerated().forEach { (index, child) in
            let newElement: PathElement = differentiableChildren ? .key(child.name) : .index(index)

            if child.children.isEmpty {
                if valueType.singleAllowed, regularExpression.validate(child.name) {
                    paths.append(readingPath.appending(newElement))
                }
            } else {
                if valueType.groupAllowed, differentiableChildren, regularExpression.validate(child.name) {
                    paths.append(readingPath.appending(newElement))
                }
                let explorer = PathExplorerXML(element: child, path: readingPath.appending(newElement))
                explorer.collectKeysPaths(in: &paths, whereKeyMatches: regularExpression, valueType: valueType)
            }
        }
    }
}
