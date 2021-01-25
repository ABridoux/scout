//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    public func getPaths(for filter: PathFilter?) -> [Path] {
        var paths = [Path]()

        switch filter {
        case .key(let regex, let valueType): collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: valueType)
        case nil: collectKeysPaths(in: &paths)
        }

        return paths
    }

    func collectKeysPaths(in paths: inout [Path]) {
        if let dict = value as? DictionaryValue {
            dict.sorted(by: { $0.key < $1.key }).forEach { (key, value) in
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
            dict.sorted(by: { $0.key < $1.key }).forEach { (key, value) in
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
