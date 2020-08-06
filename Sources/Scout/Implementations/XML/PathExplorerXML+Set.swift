//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    mutating func set(index: Int, to newValue: String) throws {

        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.arraySubscript(readingPath)
        }

        element.children[index].value = newValue
    }

    mutating func set(key: String, to newValue: String) throws {

        guard element[key].children.isEmpty else {
            throw PathExplorerError.invalidValue(newValue)
        }

        element[key].value = newValue
    }

    public mutating func set(_ path: Path, to newValue: Any) throws {
        let newValueString = try convert(newValue, to: .string)

        var currentPathExplorer = self

        try path.forEach { element in
            guard element != .count else {
                throw PathExplorerError.countWrongUsage(path: path)
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
