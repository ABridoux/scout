//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    mutating func delete(key: String) throws {
        guard var dict = value as? DictionaryValue else {
            throw PathExplorerError.dictionarySubscript(readingPath)
        }

        guard dict[key] != nil else {
            throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(dict.keys)))
        }

        dict.removeValue(forKey: key)
        value = dict
    }

    mutating func delete(at index: Int) throws {
        guard var array = value as? ArrayValue else {
            throw PathExplorerError.arraySubscript(readingPath)
        }

        if index == -1 {
            guard !array.isEmpty else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            array.removeLast()
            value = array
            return
        }

        guard 0 <= index, index < array.count else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        array.remove(at: index)
        value = array
    }

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key): try delete(key: key)
        case .index(let index): try delete(at: index)
        case .count: throw PathExplorerError.countWrongUsage(path: readingPath.appending(element))
        }
    }

    public mutating func delete(_ path: Path) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            try pathExplorer.set(element: element, to: currentExplorer.value)
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }
}
