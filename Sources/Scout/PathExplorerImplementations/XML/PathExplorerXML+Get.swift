//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerXML {

    // MARK: - Array

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    /// - parameter detailedName: If `true`, when using a dictionary filter, the keys names will be changed to reflect the filtering
    func get(at index: Int, negativeIndexEnabled: Bool = false, detailedName: Bool = true) throws -> Self {
        let copy: AEXMLElement

        switch lastGroupSample {
        case .arraySlice: copy = try getInArraySlice(at: index)
        case .dictionaryFilter: copy = try getInDictionaryFilter(at: index, detailedName: detailedName)
        case nil: copy = try getSingle(at: index, negativeIndexEnabled: negativeIndexEnabled)
        }

        return PathExplorerXML(element: copy, path: readingPath.appending(index))
    }

    func getSingle(at index: Int, negativeIndexEnabled: Bool = true) throws -> AEXMLElement {
        let index = try computeIndex(from: index, arrayCount: element.children.count, allowNegative: negativeIndexEnabled, in: readingPath)
        return element.children[index]
    }

    func getInArraySlice(at index: Int) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + PathElement.index(index).description)

        for (elementIndex, child) in element.children.enumerated() {
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(elementIndex))
            let newChild = try pathExplorer.getSingle(at: index)
            copy.addChild(newChild)
        }

        return copy
    }

    func getInDictionaryFilter(at index: Int, detailedName: Bool = true) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + PathElement.index(index).description)

        try element.children.forEach { child in
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(child.name))
            let newChild = try pathExplorer.getSingle(at: index)
            newChild.name = detailedName ? child.name + GroupSample.keySeparator + GroupSample.indexDescription(index) : child.name
            copy.addChild(newChild)
        }

        return copy
    }

    // MARK: - Dictionary

    /// - parameter detailedName: If `true`, when using a dictionary filter, the keys names will be changed to reflect the filtering
    func get(for key: String, detailedName: Bool = true) throws  -> PathExplorerXML {
        guard element.name != key else { return self } // trying to get a root element

        let copy: AEXMLElement
        switch lastGroupSample {
        case .arraySlice: copy = try getInArraySlice(for: key)
        case .dictionaryFilter: copy = try getInDictionaryFilter(for: key, detailedName: detailedName)
        case nil: copy = try getSingle(for: key)
        }

        return PathExplorerXML(element: copy, path: readingPath.appending(key))
    }

    func getSingle(for key: String) throws -> AEXMLElement {
        guard element.name != key else { return element } // trying to get a root element

        let child = element[key]

        guard child.error == nil else {
            let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(element.children.map(\.name)))
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
        }

        return child
    }

    func getInArraySlice(for key: String) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + GroupSample.keySeparator + key)

        for (index, child) in element.children.enumerated() {
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(index))
            let newChild = try pathExplorer.getSingle(for: key)
            copy.addChild(newChild)
        }
        return copy
    }

    func getInDictionaryFilter(for key: String, detailedName: Bool = true) throws -> AEXMLElement {
        let copy = AEXMLElement(name: element.name + GroupSample.keySeparator + key)

        try element.children.forEach { child in
            let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(child.name))
            let newChild = try pathExplorer.getSingle(for: key)
            newChild.name = detailedName ? child.name + GroupSample.keySeparator + newChild.name : child.name
            copy.addChild(newChild)
        }
        return copy
    }

    // MARK: - Count

    func getChildrenCount() throws -> Self {
        guard let sample = lastGroupSample else {
            let countElement = AEXMLElement(name: "", value: "\(element.children.count)")
            return PathExplorerXML(element: countElement, path: readingPath.appending(.count))
        }

        let copy = AEXMLElement(name: element.name + PathElement.count.description)
        element.children.forEach { child in
            let name: String
            switch sample {
            case .dictionaryFilter: name = child.name + GroupSample.keySeparator + PathElement.count.keyName
            case .arraySlice: name = child.name
            }

            let countChild = AEXMLElement(name: name, value: child.children.count.description)
            copy.addChild(countChild)
        }

        return PathExplorerXML(element: copy, path: readingPath.appending(.count))
    }

    // MARK: - Keys list

    func getKeysList() throws -> Self {
        var keyChildren = [AEXMLElement]()

        // get the keys names
        element.children.forEach { child in
            let keyChild = AEXMLElement(name: "key", value: child.name)
            keyChildren.append(keyChild)
        }

        // new element
        let copy = element.copy()
        copy.name = copy.name + PathElement.keysList.description
        copy.addChildren(keyChildren.sorted { $0.string < $1.string })
        return PathExplorerXML(element: copy, path: readingPath.appending(.keysList))
    }

    // MARK: - Group

    /// Returns a slice of value is it is an array
    func getArraySlice(within bounds: Bounds) throws -> PathExplorerXML {
        let slice = PathElement.slice(bounds)
        // we have to copy the element as we cannot modify its children
        let newKeyName = element.name + GroupSample.keySeparator + slice.keyName
        let copy = AEXMLElement(name: newKeyName, value: element.value, attributes: element.attributes)
        let path = readingPath.appending(slice)
        let sliceRange = try bounds.range(arrayCount: element.children.count, path: path)

        var slicedChildren = [AEXMLElement]()

        if lastGroupSample != nil {
            slicedChildren = [AEXMLElement]()
            element.children.forEach { child in
                let newChild = child.copy()
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
        let filterName = GroupSample.keySeparator + filter.keyName

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
    /// - parameter detailedName: If `true`, when using a dictionary filter, the keys names will be changed to reflect the filtering
    func get(element: PathElement, negativeIndexEnabled: Bool = true, detailedName: Bool = true) throws  -> Self {
        guard readingPath.last != .count else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }

        switch element {
        case .key(let key): return try get(for: key, detailedName: detailedName)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled, detailedName: detailedName)
        case .count: return try getChildrenCount()
        case .keysList: return try getKeysList()
        case .slice(let bounds): return try getArraySlice(within: bounds)
        case .filter(let pattern): return try getDictionaryFilter(with: pattern)
        }
    }
}