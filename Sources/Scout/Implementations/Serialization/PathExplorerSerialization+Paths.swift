//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    public func getPaths(startingAt initialPath: Path?, for filter: PathFilter?) throws -> [Path] {
        var explorer = Self(value: value, path: .empty)

        if let path = initialPath {
            try path.forEach { (element) in
                switch element {
                case .count, .keysList:
                    let context = "It cannot be used with the 'path' command"
                    throw PathExplorerError.wrongElement(element: element, command: "paths")

                case .filter, .slice, .index, .key:
                    explorer = try explorer.get(element: element, negativeIndexEnabled: true, detailedName: false)
                }
            }
        }
        var paths = [Path]()

        switch filter {
        case .key(let regex, let valueType): explorer.collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: valueType)
        case nil: explorer.collectKeysPaths(in: &paths)
        }

        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    func collectKeysPaths(in paths: inout [Path]) {
        if let dict = value as? DictionaryValue {
            dict.forEach { (key, value) in
                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))
                explorer.collectKeysPaths(in: &paths)
            }
        } else if let array = value as? ArrayValue {
            array.enumerated().forEach { (index, value) in
                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                explorer.collectKeysPaths(in: &paths)
            }
        } else {
            paths.append(readingPath)
        }
    }

    func collectKeysPaths(in paths: inout [Path], whereKeyMatches regularExpression: NSRegularExpression, valueType: PathFilter.ValueType) {
        if let dict = value as? DictionaryValue {
            dict.forEach { (key, value) in
                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))

                if valueType.groupAllowed, regularExpression.validate(key), isGroup(value: value) {
                    paths.append(readingPath.appending(key))
                }

                explorer.collectKeysPaths(in: &paths, whereKeyMatches: regularExpression, valueType: valueType)
            }
        } else if let array = value as? ArrayValue {
            array.enumerated().forEach { (index, value) in
                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                explorer.collectKeysPaths(in: &paths, whereKeyMatches: regularExpression, valueType: valueType)
            }
        } else if valueType.singleAllowed, readingPath.lastKeyComponent(matches: regularExpression) {
            paths.append(readingPath)
        }
    }
}
