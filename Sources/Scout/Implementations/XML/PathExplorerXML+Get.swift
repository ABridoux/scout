//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension PathExplorerXML {

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = false) throws -> Self {

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

    func get(for key: String) throws  -> PathExplorerXML {
        if element.name == key {
            return self
        } else {
            let child = element[key]
            guard child.error == nil else {
                throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(element.children.map { $0.name })))
            }
            return PathExplorerXML(element: element[key], path: readingPath.appending(key))
        }
    }

    /// Returns a slice of value is it is an array
    func getArraySlice(for bounds: Bounds) throws -> PathExplorerXML {
        // we have to copy the element as we cannot modify its children
        let copy = AEXMLElement(name: element.name, value: element.value, attributes: element.attributes)
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let sliceRange = try bounds.range(lastValidIndex: element.children.count - 1, path: path)

        let slicedChildren = Array(element.children[sliceRange])
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
            return try getArraySlice(for: bounds)
        }
    }
}
