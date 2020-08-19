//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

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
                try delete(key: key, in: &explorers, in: currentPath)

            case .index(let index):
                try delete(index: index, in: &explorers, in: currentPath)

            case .slice(let bounds):
                try deleteSlice(within: bounds, in: &explorers, path: currentPath)

            case .filter(let pattern):
                try deleteFilter(with: pattern, in: &explorers, path: currentPath)

            case .count:
                throw PathExplorerError.wrongUsage(of: .count, in: currentPath)
            }
        }

        explorers.forEach { pathExplorer in
            pathExplorer.element.removeFromParent()

            if deleteIfEmpty, pathExplorer.element.parent?.children.isEmpty ?? false {
                pathExplorer.element.parent?.removeFromParent()
            }
        }
    }

    func delete(key: String, in explorers: inout [Self], in path: Path) throws {
        for (index, pathExplorer) in explorers.enumerated() {
            let element = try pathExplorer.getSimple(key: key)
            let newPathExplorer = PathExplorerXML(element: element, path: path)
            explorers[index] = newPathExplorer
        }
    }

    func delete(index: Int, in explorers: inout [Self], in path: Path) throws {
        for (explorerIndex, pathExplorer) in explorers.enumerated() {
            let element = try pathExplorer.getSimple(index: index)
            let newPathExplorer = PathExplorerXML(element: element, path: path)
            explorers[explorerIndex] = newPathExplorer
        }
    }

    func deleteSlice(within bounds: Bounds, in explorers: inout [Self], path: Path) throws {
        var newElementsToDelete = [PathExplorerXML]()

        try explorers.forEach { pathExplorer in
            let element = pathExplorer.element
            let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: path)
            let newChildren = element.children[sliceRange]
            var newPathExplorers = [PathExplorerXML]()

            for (index, element) in newChildren.enumerated() {
                let pathExplorer = PathExplorerXML(element: element, path: path.appending(index))
                newPathExplorers.append(pathExplorer)
            }
            newElementsToDelete.append(contentsOf: newPathExplorers)
        }

        explorers = newElementsToDelete
    }
    
    func deleteFilter(with pattern: String, in explorers: inout [Self], path: Path) throws {
        #warning("To be implemented")
    }

    mutating func delete(at index: Int, negativeIndexEnabled: Bool = false) throws {
        if negativeIndexEnabled, index == .lastIndex {
            guard let last = element.children.last else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
            }

            last.removeFromParent()
        }

        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
        }

        element.children[index].removeFromParent()
    }

    mutating func delete(at key: String) throws {
        let child = element[key]
        guard child.error == nil else {
            let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(element.children.map { $0.name }))
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
        }

        child.removeFromParent()
    }
}
