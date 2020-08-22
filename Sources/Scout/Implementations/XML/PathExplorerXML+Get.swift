//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerXML {

    // MARK: - Array

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    /// - parameter ignoreArraySlicing: If `true`, the fact that self is part of a slicing will be ignore to simple get the index
    func get(at index: Int, negativeIndexEnabled: Bool = false) throws -> Self {
        let copy: AEXMLElement

        switch lastGroupSample {
        case .arraySlice: copy = try getInArraySlice(index: index)
        case .dictionaryFilter: copy = try getInDictionaryFilter(index: index)
        case nil: copy = try getSimple(index: index, negativeIndexEnabled: negativeIndexEnabled)
        }

        return PathExplorerXML(element: copy, path: readingPath.appending(index))
    }

    func getSimple(index: Int, negativeIndexEnabled: Bool = true) throws -> AEXMLElement {
        if negativeIndexEnabled, index == .lastIndex {
            guard let last = element.children.last else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
            }
            return last

        } else {
            guard element.children.count > index, index >= 0 else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
            }
            return element.children[index]
        }
    }

    func getInArraySlice(index: Int) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + "[\(index)]")

        for (elementIndex, child) in element.children.enumerated() {
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(elementIndex))
            let newChild = try pathExplorer.getSimple(index: index)
            copy.addChild(newChild)
        }

        return copy
    }

    func getInDictionaryFilter(index: Int) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + "[\(index)]")

        try element.children.forEach { child in
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(child.name))
            let newChild = try pathExplorer.getSimple(index: index)
            newChild.name = child.name + "[\(index)]"
            copy.addChild(newChild)
        }

        return copy
    }

    // MARK: - Dictionary

    /// - parameter ignoreArraySlicing: If `true`, the fact that self is part of a slicing will be ignore to simple get the index
    func get(for key: String) throws  -> PathExplorerXML {
        let copy: AEXMLElement

        guard element.name != key else { return self } // trying to get a root element

        switch lastGroupSample {
        case .arraySlice: copy = try getInArraySlice(key: key)
        case .dictionaryFilter: copy = try getInDictionaryFilter(key: key)
        case nil: copy = try getSimple(key: key)
        }

        return PathExplorerXML(element: copy, path: readingPath.appending(key))
    }

    func getSimple(key: String) throws -> AEXMLElement {

        guard element.name != key else { return element } // trying to get a root element

        let child = element[key]

        guard child.error == nil else {
            let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(element.children.map { $0.name }))
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
        }

        return child
    }

    func getInArraySlice(key: String) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name  + ".\(key.description)")

        for (index, child) in element.children.enumerated() {
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(index))
            let newChild = try pathExplorer.getSimple(key: key)
            copy.addChild(newChild)
        }
        return copy
    }

    func getInDictionaryFilter(key: String) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name  + ".\(key.description)")

        try element.children.forEach { child in
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(child.name))
            let newChild = try pathExplorer.getSimple(key: key)
            newChild.name = child.name + "." + newChild.name
            copy.addChild(newChild)
        }
        return copy
    }

    func getChildrenCount() throws -> Self {
        if let sample = lastGroupSample {
            let copy = AEXMLElement(name: element.name + PathElement.count.description)

            element.children.forEach { child in
                let name: String

                switch sample {
                case .dictionaryFilter: name = child.name + PathElement.count.description
                case .arraySlice: name = child.name
                }

                let countChild = AEXMLElement(name: name, value: child.children.count.description)
                copy.addChild(countChild)
            }
            return PathExplorerXML(element: copy, path: readingPath.appending(.count))
        }

        return PathExplorerXML(element: .init(name: "", value: "\(self.element.children.count)", attributes: [:]),
                               path: readingPath.appending(.count))
    }

    // MARK: - Group

    /// Returns a slice of value is it is an array
    func getArraySlice(within bounds: Bounds) throws -> PathExplorerXML {
        let slice = PathElement.slice(bounds)
        // we have to copy the element as we cannot modify its children
        let copy = AEXMLElement(name: element.name + slice.description, value: element.value, attributes: element.attributes)
        let path = readingPath.appending(slice)
        let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: path)

        var slicedChildren = [AEXMLElement]()

        if lastGroupSample != nil {
            slicedChildren = [AEXMLElement]()
            element.children.forEach { child in
                let newChild = AEXMLElement(name: child.name, value: child.value, attributes: child.attributes)
                let newSlicedChildren = Array(child.children[sliceRange])
                newChild.addChildren(newSlicedChildren)
                slicedChildren.append(newChild)
            }
        } else {
            slicedChildren = Array(element.children[sliceRange])
        }

        // add the sliced chilren to copy
        copy.addChildren(slicedChildren)

        return PathExplorerXML(element: copy, path: path)
    }

    func getDictionaryFilter(with pattern: String) throws -> Self {
        let filter = PathElement.filter(pattern)
        let path = readingPath.appending(filter)
        let regex = try NSRegularExpression(pattern: pattern, path: path)
        let filterName = "." + PathElement.filter(pattern).description

        var filteredChildren = [AEXMLElement]()

        if let sample = lastGroupSample {
            filteredChildren = [AEXMLElement]()

            element.children.forEach { child in
                let newName: String
                switch sample {
                case .dictionaryFilter: newName = child.name + filterName
                case .arraySlice: newName = child.name
                }

                let newChild = AEXMLElement(name: newName, value: child.value, attributes: child.attributes)
                let newSlicedChildren = child.children.filter { regex.validate($0.name) }
                newChild.addChildren(newSlicedChildren)
                filteredChildren.append(newChild)
            }
        } else {
            filteredChildren = element.children.filter { regex.validate($0.name) }
        }

        let copy = AEXMLElement(name: element.name + filterName, value: element.value, attributes: element.attributes)

        copy.addChildren(filteredChildren)

        return PathExplorerXML(element: copy, path: path)
    }

    // MARK: - General

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element: PathElement, negativeIndexEnabled: Bool = true) throws  -> Self {
        guard readingPath.last != .count else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }

        switch element {
        case .key(let key): return try get(for: key)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)
        case .count: return try getChildrenCount()
        case .slice(let bounds): return try getArraySlice(within: bounds)
        case .filter(let pattern): return try getDictionaryFilter(with: pattern)
        }
    }
}
