//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerXML {

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = false) throws -> Self {

        if negativeIndexEnabled, index == -1 {
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

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(element: PathElement, negativeIndexEnabled: Bool = true) throws  -> Self {
        guard readingPath.last != .count else {
            throw PathExplorerError.countWrongUsage(path: readingPath)
        }

        switch element {
        case .key(let key): return try get(for: key)
        case .index(let index): return try get(at: index, negativeIndexEnabled: negativeIndexEnabled)
        case .count:
            return PathExplorerXML(element: .init(name: "", value: "\(self.element.children.count)", attributes: [:]),
                                   path: readingPath.appending(element))
        }
    }
}
