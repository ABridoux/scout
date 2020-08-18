//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    mutating func delete(key: String) throws {

        if isArray, isArraySlice {
            // array slice. Try to find the common key in the dictionaries and delete it
            var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath.appending(key)))

            for (index, oldDict) in array.enumerated() {
                let path = readingPath.appending(.index(index))
                var pathExplorer = PathExplorerSerialization(value: oldDict, path: path)
                try? pathExplorer.delete(key: key) // preferable to ignore a key which is already missing 
                array[index] = pathExplorer.value
            }

            value = array
        } else {
            var dict = try getDictAndValueFor(key: key).dictionary
            dict.removeValue(forKey: key)
            value = dict
        }
    }

    mutating func delete(at index: Int) throws {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if precedeKeyOrSliceAfterSlicing {
            // array slice. Try to delete index in the arrays

            for (indexElement, oldArray) in array.enumerated() {
                let path = readingPath.appending(.index(indexElement))
                var pathExplorer = PathExplorerSerialization(value: oldArray, path: path)
                try? pathExplorer.delete(at: index) // preferable to ignore an index which is already missing
                array[indexElement] = pathExplorer.value
            }

            value = array

        } else {
            if index == .lastIndex {
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
    }

    mutating func deleteSlice(within bounds: Bounds) throws {
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let array = try cast(value, as: .array, orThrow: .wrongUsage(of: .slice(bounds), in: path))

        let range = try bounds.range(lastValidIndex: array.count - 1, path: path)
        let newArray = array.remove(in: range)
        value = newArray
    }

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key): try delete(key: key)
        case .index(let index): try delete(at: index)
        case .count: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try deleteSlice(within: bounds)
        }
    }

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool = false) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            if deleteIfEmpty, currentExplorer.isEmpty {
                try pathExplorer.delete(element: element)
            } else {
                try pathExplorer.set(element: element, to: currentExplorer.value)
            }
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }
}
