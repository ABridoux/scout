//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

// MARK: - Public

extension PathExplorerXML {

    public mutating func add(_ newValue: Any, at path: Path) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: .string)

        var path = path
        let lastElement = path.removeLast()

        var currentPathExplorer = self

        try path.forEach { element in
            let element = element == .count ? PathElement.index(currentPathExplorer.element.children.count) : element

            if let pathExplorer = try? currentPathExplorer.get(element: element, negativeIndexEnabled: true) {
                // the key exist. Just keep parsing
                currentPathExplorer = pathExplorer
            } else {
                // the key does not exist. Add a new key to it
                let keyName = element.key ?? currentPathExplorer.element.childrenName
                currentPathExplorer.element.addChild(name: keyName, value: nil)
                currentPathExplorer = try currentPathExplorer.get(element: element)
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement)
    }
}

// MARK: - Internal

extension PathExplorerXML {

    mutating func add(newValue: String, for key: String) throws {
        if let existingChild = element.firstDescendant(where: { $0.name == key }) {
            // set the value of the child if one exists with the given key
            existingChild.value = newValue
        } else {
            // otherwise add the child
            element.addChild(name: key, value: newValue)
        }
    }

    mutating func add(newValue: String, at index: Int) throws {
        let keyName = element.childrenName

        if index == 0 || index == .lastIndex, element.children.isEmpty {
            // allow to add an element if the array is empty and the index is 0 or -1
            element.addChild(name: keyName, value: newValue)
            return
        }

        let index = try computeIndex(from: index, arrayCount: element.children.count, allowNegative: true, in: readingPath)

        insertChild(named: keyName, withValue: newValue, at: index)
    }

    mutating func append(newValue: String) {
        element.addChild(name: element.childrenName, value: newValue)
    }

    mutating func add(_ newValue: Any, at path: PathElementRepresentable...) throws {
        try add(newValue, at: Path(path))
    }

    mutating func add(_ newValue: String, for pathElement: PathElement) throws {

        switch pathElement {

        case .key(let key): try add(newValue: newValue, for: key)
        case .index(let index): try add(newValue: newValue, at: index)
        case .count: append(newValue: newValue)
        case .keysList, .slice, .filter: throw PathExplorerError.wrongUsage(of: pathElement, in: readingPath)
        }
    }

    mutating func insertChild(named keyName: String, withValue value: String, at index: Int) {
        // we have to copy the element as we cannot modify its children
        let copy = element.copyFlat()

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
}
