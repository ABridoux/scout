//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension PathExplorerXML {

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    /// - parameter ignoreArraySlicing: If `true`, the fact that self is part of a slicing will be ignore to simple get the index
    func get(at index: Int, negativeIndexEnabled: Bool = false, ignoreArraySlicing: Bool = false) throws -> Self {
        if precedeKeyOrSliceAfterSlicing  && !ignoreArraySlicing {
            // Array slice. Try to find the common index in the array
            let copy = AEXMLElement(name: element.name + "[\(index)]")
            for (elementIndex, child) in element.children.enumerated() {
                let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(elementIndex))
                let newChild = try pathExplorer.get(at: index).element
                copy.addChild(newChild)
            }
            return PathExplorerXML(element: copy, path: readingPath.appending(index))
        }

        if negativeIndexEnabled, index == .lastIndex {
            guard let last = element.children.last else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
            }

            return PathExplorerXML(element: last, path: readingPath.appending(index))
        }

        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
        }

        return PathExplorerXML(element: element.children[index], path: readingPath.appending(index))
    }

    /// - parameter ignoreArraySlicing: If `true`, the fact that self is part of a slicing will be ignore to simple get the index
    func get(for key: String, ignoreArraySlicing: Bool = false) throws  -> PathExplorerXML {
        if precedeKeyOrSliceAfterSlicing && !ignoreArraySlicing {
            // Array slice. Try to find the common key in the array
            let copy = AEXMLElement(name: element.name  + ".\(key.description)")
            for (index, child) in element.children.enumerated() {
                let pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(index))
                let newChild = try pathExplorer.get(for: key).element
                copy.addChild(newChild)
            }
            return PathExplorerXML(element: copy, path: readingPath.appending(key))
        } else if element.name == key {
            // trying to get a root element
            return self
        } else {
            // classic dictionary
            let child = element[key]
            guard child.error == nil else {
                let bestMatch = key.bestJaroWinklerMatchIn(propositions: Set(element.children.map { $0.name }))
                throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: bestMatch)
            }

            return PathExplorerXML(element: element[key], path: readingPath.appending(key))
        }
    }

    /// Returns a slice of value is it is an array
    func getArraySlice(within bounds: Bounds) throws -> PathExplorerXML {
        let slice = PathElement.slice(bounds)
        // we have to copy the element as we cannot modify its children
        let copy = AEXMLElement(name: element.name + slice.description, value: element.value, attributes: element.attributes)
        let path = readingPath.appending(slice)
        let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: path)

        let slicedChildren = Array(element.children[sliceRange])
        // add the sliced chilren to copy
        copy.addChildren(slicedChildren)

        return PathExplorerXML(element: copy, path: path)
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element: PathElement, negativeIndexEnabled: Bool = true) throws  -> Self {
        guard readingPath.last != .count else {
            throw PathExplorerError.wrongUsage(of: .count, in: readingPath)
        }

        switch element {
        case .key(let key): return try get(for: key)

        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)

        case .count:
            return PathExplorerXML(element: .init(name: "", value: "\(self.element.children.count)", attributes: [:]),
                                   path: readingPath.appending(element))

        case .slice(let bounds):
            return try getArraySlice(within: bounds)
        }
    }
}
