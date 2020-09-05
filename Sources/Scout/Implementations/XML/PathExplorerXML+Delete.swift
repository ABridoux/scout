//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML
import Foundation

extension PathExplorerXML {

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool = false) throws {
        var currentPath = Path()

        // for each encountered slice, we'll add the sliced explorers in the array to then
        // delete the common key in each of them
        var explorers = [self]

        try path.forEach { pathElement in
            currentPath.append(pathElement)

            switch pathElement {
            case .key(let key):
                try delete(for: key, in: &explorers, in: currentPath)

            case .index(let index):
                try delete(at: index, in: &explorers, in: currentPath)

            case .slice(let bounds):
                try delete(.arraySlice(bounds), in: &explorers, path: currentPath)

            case .filter(let pattern):
                try delete(.dictionaryFilter(pattern), in: &explorers, path: currentPath)

            case .count, .keysList:
                throw PathExplorerError.wrongUsage(of: pathElement, in: currentPath)
            }
        }

        explorers.forEach { pathExplorer in
            pathExplorer.element.removeFromParent()

            if deleteIfEmpty, pathExplorer.element.parent?.children.isEmpty ?? false {
                pathExplorer.element.parent?.removeFromParent()
            }
        }
    }

    func delete(for key: String, in explorers: inout [Self], in path: Path) throws {
        for (index, pathExplorer) in explorers.enumerated() {
            let element = try pathExplorer.getSingle(for: key)
            let newPathExplorer = PathExplorerXML(element: element, path: path)
            explorers[index] = newPathExplorer
        }
    }

    func delete(at index: Int, in explorers: inout [Self], in path: Path) throws {
        for (explorerIndex, pathExplorer) in explorers.enumerated() {
            let element = try pathExplorer.getSingle(at: index)
            let newPathExplorer = PathExplorerXML(element: element, path: path)
            explorers[explorerIndex] = newPathExplorer
        }
    }

    func delete(_ groupSample: GroupSample, in explorers: inout [Self], path: Path) throws {
        var newElementsToDelete = [PathExplorerXML]()

        try explorers.forEach { pathExplorer in
            let element = pathExplorer.element

            let newChildren: [AEXMLElement]
            switch groupSample {
            case .dictionaryFilter(let pattern):
                let regex = try NSRegularExpression(pattern: pattern, path: readingPath)
                newChildren = element.children.filter { regex.validate($0.name) }
            case .arraySlice(let bounds):
                let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: path)
                newChildren = Array(element.children[sliceRange])
            }

            var newPathExplorers = [PathExplorerXML]()
            newChildren.forEach { element in
                let path = path.appending(groupSample.pathElement)
                let pathExplorer = PathExplorerXML(element: element, path: path)
                newPathExplorers.append(pathExplorer)
            }
            newElementsToDelete.append(contentsOf: newPathExplorers)
        }

        explorers = newElementsToDelete
    }
}
