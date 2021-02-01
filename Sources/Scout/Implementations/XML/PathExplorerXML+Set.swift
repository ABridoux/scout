//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    public mutating func set(_ path: Path, to newValue: Any) throws {
        let newValueString = try convert(newValue, to: .string)

        var currentPathExplorer = self

        try path.forEach { element in
            guard element != .count else {
                throw PathExplorerError.wrongUsage(of: .count, in: path)
            }
            currentPathExplorer = try currentPathExplorer.get(element: element)
        }

        guard currentPathExplorer.element.children.isEmpty else {
            throw PathExplorerError.wrongValueForKey(value: newValueString, element: .key(currentPathExplorer.element.name))
        }

        currentPathExplorer.element.value = newValueString
    }

    // -- Set key name

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        try validateLast(element: currentPathExplorer.readingPath.last, in: path)

        currentPathExplorer.element.name = newKeyName
    }
}
