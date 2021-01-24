//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    // MARK: - Array

    mutating func delete(at index: Int) throws {

        switch lastGroupSample {

        case .arraySlice:
            var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try delete(at: index, inArarySlice: &arraySlice)
            value = arraySlice

        case .dictionaryFilter:
            var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try delete(at: index, inDictionaryFilter: &dictionaryFilter)
            value = dictionaryFilter

        case nil:
            value = try deleteSingle(at: index)
        }
    }

    func deleteSingle(at index: Int) throws -> ArrayValue {
        var array = try cast(value, as: .array, orThrow: .arraySubscript(readingPath))

        if index == .lastIndex {
            if array.isEmpty {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
            }
            array.removeLast()
            return array
        }

        guard 0 <= index, index < array.count else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: array.count)
        }

        array.remove(at: index)

        return array
    }

    func delete(at index: Int, inArarySlice array: inout ArrayValue) throws {
        for (valueIndex, oldValue) in array.enumerated() {
            let path = readingPath.appending(valueIndex)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            array[valueIndex] = try pathExplorer.deleteSingle(at: index)
        }
    }

    func delete(at index: Int, inDictionaryFilter dictionary: inout DictionaryValue) throws {
        try dictionary.forEach { (keyValue, oldValue) in
            let path = readingPath.appending(keyValue)
            let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
            dictionary[keyValue] = try pathExplorer.deleteSingle(at: index)
        }
    }

    // MARK: - Dictionary

      mutating func delete(for key: String) throws {

          switch lastGroupSample {

          case .arraySlice:
              var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
              try delete(for: key, inArraySlice: &arraySlice)
              value = arraySlice

          case .dictionaryFilter:
              var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
              try delete(for: key, inDictionaryFilter: &dictionaryFilter)
              value = dictionaryFilter

          case nil:
              value = try deleteSingle(for: key)
          }
      }

      func deleteSingle(for key: String) throws -> DictionaryValue {
          var dict = try getDictAndValueFor(for: key).dictionary
          dict.removeValue(forKey: key)
          return dict
      }

      func delete(for key: String, inArraySlice array: inout ArrayValue) throws {
          for (index, oldValue) in array.enumerated() {
              let path = readingPath.appending(index)
              let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
              array[index] = try pathExplorer.deleteSingle(for: key)
          }
      }

      func delete(for key: String, inDictionaryFilter dictionary: inout DictionaryValue) throws {
          try dictionary.forEach { (keyValue, oldValue) in
              let path = readingPath.appending(keyValue)
              let pathExplorer = PathExplorerSerialization(value: oldValue, path: path)
              dictionary[keyValue] = try pathExplorer.deleteSingle(for: key)
          }
      }

    // MARK: - Group

    mutating func deleteSingle(_ groupSample: GroupSample) throws {
        switch groupSample {
        case .arraySlice(let bounds): try deleteSingleArraySlice(within: bounds)
        case .dictionaryFilter(let pattern): try deleteSingleDictionaryFilter(with: pattern)
        }
    }

    mutating func deleteSingleArraySlice(within bounds: Bounds) throws {
        let slice = PathElement.slice(bounds)
        let path = readingPath.appending(slice)
        let array = try cast(value, as: .array, orThrow: .wrongUsage(of: slice, in: path))

        let range = try bounds.range(lastValidIndex: array.count - 1, path: path)
        let newArraySlice = array.remove(in: range)
        value = newArraySlice
    }

    mutating func deleteSingleDictionaryFilter(with pattern: String) throws {
        let filter = PathElement.filter(pattern)
        let regex = try NSRegularExpression(pattern: pattern, path: readingPath)
        let path = readingPath.appending(filter)

        if isArray {
            let array = try cast(value, as: .array(.string), orThrow: .wrongUsage(of: filter, in: path))
            value = array.filter { !regex.validate($0) }
            return
        }

        var dict = try cast(value, as: .dictionary, orThrow: .wrongUsage(of: filter, in: path))

        for key in dict.keys where regex.validate(key) {
            dict.removeValue(forKey: key)
        }

        value = dict
    }

    func delete(_ groupSample: GroupSample, inArraySlice array: inout ArrayValue) throws {
        for (index, element) in array.enumerated() {
            let path = readingPath.appending(index)
            var pathExplorer = PathExplorerSerialization(value: element, path: path)
            try pathExplorer.deleteSingle(groupSample)
            array[index] = pathExplorer.value
        }
    }

    func delete(_ groupSample: GroupSample, inDictionaryFilter dictionary: inout DictionaryValue) throws {
        try dictionary.forEach { (key, value) in
            let path = readingPath.appending(key)
            var pathExplorer = PathExplorerSerialization(value: value, path: path)
            try pathExplorer.deleteSingle(groupSample)
            dictionary[key] = pathExplorer.value
        }
    }

    mutating func deleteArraySlice(within bounds: Bounds) throws {
        switch lastGroupSample {

        case .arraySlice:
            var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try delete(.arraySlice(bounds), inArraySlice: &arraySlice)
            value = arraySlice

        case .dictionaryFilter:
            var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try delete(.arraySlice(bounds), inDictionaryFilter: &dictionaryFilter)
            value = dictionaryFilter

        case nil:
            try deleteSingleArraySlice(within: bounds)
        }
    }

    mutating func deleteDictionaryFilter(with pattern: String) throws {
        switch lastGroupSample {
        case .arraySlice:
            var arraySlice = try cast(value, as: .array, orThrow: .groupSampleConversionError(readingPath))
            try delete(.dictionaryFilter(pattern), inArraySlice: &arraySlice)
            value = arraySlice

        case .dictionaryFilter:
            var dictionaryFilter = try cast(value, as: .dictionary, orThrow: .groupSampleConversionError(readingPath))
            try delete(.dictionaryFilter(pattern), inDictionaryFilter: &dictionaryFilter)
            value = dictionaryFilter

        case nil:
            try deleteSingleDictionaryFilter(with: pattern)

        }
    }

    // MARK: - Regular expression

    public mutating func delete(regularExpression: NSRegularExpression, deleteIfEmpty: Bool) throws {
        if isDictionary {
            try deleteDict(regularExpression: regularExpression, deleteIfEmpty: deleteIfEmpty)
        } else if isArray {
            try deleteArray(regularExpression: regularExpression, deleteIfEmpty: deleteIfEmpty)
        }
    }

    mutating func deleteDict(regularExpression: NSRegularExpression, deleteIfEmpty: Bool) throws {
        var dict = try cast(value, as: .dictionary, orThrow: .dictionarySubscript(readingPath))

        // remove the dict keys matching the regex
        for key in dict.keys where regularExpression.validate(key) {
            dict.removeValue(forKey: key)
        }

        // call the deletion funcion on children
        try dict.forEach { (key, value) in
            var explorer = PathExplorerSerialization(value: value)
            try explorer.delete(regularExpression: regularExpression, deleteIfEmpty: deleteIfEmpty)

            if deleteIfEmpty, explorer.isEmpty {
                dict.removeValue(forKey: key)
            } else {
                dict[key] = explorer.value
            }
        }

        value = dict
    }

    mutating func deleteArray(regularExpression: NSRegularExpression, deleteIfEmpty: Bool) throws {
        let array = try cast(value, as: .array, orThrow: .dictionarySubscript(readingPath))

        // call the deletion funcion on children
        value = try array.compactMap { (value) -> Any? in
            var explorer = PathExplorerSerialization(value: value)
            try explorer.delete(regularExpression: regularExpression, deleteIfEmpty: deleteIfEmpty)

            if deleteIfEmpty, explorer.isEmpty {
                return nil
            } else {
                return explorer.value
            }
        }
    }

    // MARK: - General

    mutating func delete(element: PathElement) throws {
        switch element {

        case .key(let key): try delete(for: key)
        case .index(let index): try delete(at: index)
        case .count, .keysList: throw PathExplorerError.wrongUsage(of: element, in: readingPath.appending(element))
        case .slice(let bounds): try deleteArraySlice(within: bounds)
        case .filter(let pattern): try deleteDictionaryFilter(with: pattern)
        }
    }

    /// - parameter deleteIfEmpty: If `true`, the group values will be deleted when left empty
    public mutating func delete(_ path: Path, deleteIfEmpty: Bool = false) throws {
        guard !path.isEmpty else { return }

        let (pathExplorers, path, lastElement) = try getExplorers(from: path)

        guard var currentExplorer = pathExplorers.last else {
            throw PathExplorerError.underlyingError("Internal error while exploring the path '\(path.description)' to set it")
        }

        try currentExplorer.delete(element: lastElement)

        for (pathExplorer, element) in zip(pathExplorers, path).reversed() {
            var pathExplorer = pathExplorer
            pathExplorer.allowEmptyGroups = !deleteIfEmpty
            try pathExplorer.set(element: element, to: currentExplorer.value)
            currentExplorer = pathExplorer
        }

        self = currentExplorer
    }
}
