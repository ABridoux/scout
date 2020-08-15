//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    public mutating func delete(_ path: Path) throws {
        var currentPathExplorer = self

        var pathCopy = path
        guard !path.isEmpty else { return }
        let last = pathCopy.removeLast()

        try validateLast(element: last, in: path)

        try pathCopy.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        switch last {
        case .slice(let bounds):
            let currentElement = currentPathExplorer.element
            let range = try bounds.range(lastValidIndex: currentElement.children.count - 1, path: path)
            let childrenToRemove = currentElement.children[range]
            childrenToRemove.forEach { $0.removeFromParent() }
        default:
            currentPathExplorer = try currentPathExplorer.get(element: last)
            currentPathExplorer.element.removeFromParent()
        }
    }

    public mutating func delete(_ path: PathElementRepresentable...) throws {
        try delete(Path(path))
    }
}
