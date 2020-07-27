//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    public mutating func delete(_ path: Path) throws {
        var currentPathExplorer = self

        guard path.last != .count else {
            throw PathExplorerError.countWrongUsage(path: path)
        }

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        currentPathExplorer.element.removeFromParent()
    }

    public mutating func delete(_ path: PathElementRepresentable...) throws {
        try delete(Path(path))
    }
}
