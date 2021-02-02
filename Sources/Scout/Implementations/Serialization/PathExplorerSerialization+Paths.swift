//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    public func listPaths(startingAt initialPath: Path?, for filter: PathElementFilter?, valueType: PathElementFilter.ValueType) throws -> [Path] {
        var explorer = Self(value: value, path: .empty)

        if let path = initialPath {
            try path.forEach { (element) in
                switch element {
                case .count, .keysList:
                    throw PathExplorerError.wrongElement(element: element, command: "paths")

                case .filter, .slice, .index, .key:
                    explorer = try explorer.get(element: element, negativeIndexEnabled: true, detailedName: false)
                }
            }
        }
        var paths = [Path]()

        switch filter {
        case .key(let regex): explorer.collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: valueType)
        case nil: explorer.collectKeysPaths(in: &paths, valueType: valueType)
        }

        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    func collectKeysPaths(in paths: inout [Path], valueType: PathElementFilter.ValueType) {
        switch value {

        case let dict as DictionaryValue:
            dict.forEach { (key, value) in
                if valueType.groupAllowed, isGroup(value: value) {
                    paths.append(readingPath.appending(key))
                }

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))
                explorer.collectKeysPaths(in: &paths, valueType: valueType)
            }

        case let array as ArrayValue:
            array.enumerated().forEach { (index, value) in
                if valueType.groupAllowed, isGroup(value: value) {
                    paths.append(readingPath.appending(index))
                }

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                explorer.collectKeysPaths(in: &paths, valueType: valueType)
            }
        default:
            if valueType.singleAllowed {
                paths.append(readingPath)
            }
        }
    }

    func collectKeysPaths(in paths: inout [Path], whereKeyMatches regularExpression: NSRegularExpression, valueType: PathElementFilter.ValueType) {
        switch value {

        case let dict as DictionaryValue:
            dict.forEach { (key, value) in
                if valueType.groupAllowed, regularExpression.validate(key), isGroup(value: value) {
                    paths.append(readingPath.appending(key))
                }

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))
                explorer.collectKeysPaths(in: &paths, whereKeyMatches: regularExpression, valueType: valueType)
            }

        case let array as ArrayValue:
            array.enumerated().forEach { (index, value) in

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                explorer.collectKeysPaths(in: &paths, whereKeyMatches: regularExpression, valueType: valueType)
            }

        default:
            if valueType.singleAllowed, readingPath.lastKeyComponent(matches: regularExpression) {
                paths.append(readingPath)
            }
        }
    }
}
