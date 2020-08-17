//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    public mutating func delete(_ path: Path) throws {
        var currentPath = Path()

        var elementsToDelete = [self]

        try path.forEach { pathElement in
            currentPath.append(pathElement)

            switch pathElement {
            case .key(let key):
                for (index, pathExplorer) in elementsToDelete.enumerated() {
                    elementsToDelete[index] = try pathExplorer.get(for: key, ignoreArraySlicing: true)
                }

            case .index(let elementIndex):
                for (index, pathExplorer) in elementsToDelete.enumerated() {
                    elementsToDelete[index] = try pathExplorer.get(at: elementIndex, negativeIndexEnabled: true, ignoreArraySlicing: true)
                }

            case .slice(let bounds):
                var newElementsToDelete = [PathExplorerXML]()

                try elementsToDelete.forEach { pathExplorer in
                    let element = pathExplorer.element
                    let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: currentPath)
                    let newChildren = element.children[sliceRange]
                    var newPathExplorers = [PathExplorerXML]()

                    for (index, element) in newChildren.enumerated() {
                        let pathExplorer = PathExplorerXML(element: element, path: currentPath.appending(index))
                        newPathExplorers.append(pathExplorer)
                    }
                    newElementsToDelete.append(contentsOf: newPathExplorers)
                }

                elementsToDelete = newElementsToDelete

            case .count:
                throw PathExplorerError.wrongUsage(of: .count, in: currentPath)
            }
        }

        elementsToDelete.forEach { pathExplorer in
            pathExplorer.element.removeFromParent()
        }
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

    public mutating func delete(_ path: PathElementRepresentable...) throws {
        try delete(Path(path))
    }
}
