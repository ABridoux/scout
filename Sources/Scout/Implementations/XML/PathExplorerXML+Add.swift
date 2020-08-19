//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension PathExplorerXML {

    mutating func add(newValue: String, forKey key: String) throws {
        if let existingChild = element.firstDescendant(where: { $0.name == key }) {
            // set the value of the child if one exists with the given key
            existingChild.value = newValue
        } else {
            // otherwise add the child
            element.addChild(name: key, value: newValue, attributes: [:])
        }
    }

    mutating func add(newValue: String, at index: Int) throws {
        let keyName = element.childrenName

        if index == .lastIndex || element.children.isEmpty {
            // no children so add the child as the first one
            element.addChild(name: keyName, value: newValue, attributes: [:])

        } else if index >= 0, element.children.count > index {
            insertChild(named: keyName, withValue: newValue, at: index)

        } else {
            throw PathExplorerError.wrongValueForKey(value: newValue, element: .index(index))
        }
    }

    public mutating func add(_ newValue: Any, at path: PathElementRepresentable...) throws {
        try add(newValue, at: Path(path))
    }

    /// Add the new value to the array or dictionary value
    /// - Parameters:
    ///   - newValue: The new value to add
    ///   - element: If string, try to add the new value to the dictionary. If int, try to add the new value to the array. `-1` will add the value at the end of the array.
    /// - Throws: if self cannot be subscript with the given element
    mutating func add(_ newValue: String, for pathElement: PathElement) throws {

        switch pathElement {

        case .key(let key): try add(newValue: newValue, forKey: key)
        case .index(let index): try add(newValue: newValue, at: index)
        case .count, .slice, .filter: throw PathExplorerError.wrongUsage(of: pathElement, in: readingPath)
        }
    }

    mutating func insertChild(named keyName: String, withValue value: String, at index: Int) {
        // we have to copy the element as we cannot modify its children
        let copy = AEXMLElement(name: element.name, value: element.value, attributes: element.attributes)

        // parse the children and just adding them until we reach index to insert the new child
        for childIndex in 0...element.children.count {
            switch childIndex {

            case 0..<index:
                copy.addChild(element.children[childIndex])

            case index:
                copy.addChild(name: keyName, value: value, attributes: [:])

            case index+1...element.children.count:
                copy.addChild(element.children[childIndex - 1])

            default: break
            }
        }

        if let parent = element.parent {
            // we have to replace the child of the parent with the copy
            element.removeFromParent()
            parent.addChild(copy)
        } else {
            // the element is the root element, so simply change it
            element = copy
        }
    }

    public mutating func add(_ newValue: Any, at path: Path) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: .string)

        var path = path
        let lastElement = path.removeLast()

        try validateLast(element: lastElement, in: path.appending(lastElement))

        var currentPathExplorer = self

        try path.forEach { element in
            if let pathExplorer = try? currentPathExplorer.get(element: element, negativeIndexEnabled: false) {
                // the key exist. Just keep parsing
                currentPathExplorer = pathExplorer
            } else {
                // the key does not exist. Add a new key to it
                let keyName = element.key ?? currentPathExplorer.element.childrenName
                currentPathExplorer.element.addChild(name: keyName, value: nil, attributes: [:])

                if case let .index(index) = element, index == .lastIndex {
                    // get the last element
                    let childrenCount = currentPathExplorer.element.children.count - 1
                    currentPathExplorer = try currentPathExplorer.get(element: .index(childrenCount))
                } else {
                    currentPathExplorer = try currentPathExplorer.get(element: element)
                }
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement)
    }
}
