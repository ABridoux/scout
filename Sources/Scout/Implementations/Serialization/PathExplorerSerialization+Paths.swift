//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerSerialization {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
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

        explorer.collectKeysPaths(in: &paths, filter: filter)
        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    func collectKeysPaths(in paths: inout [Path], filter: PathsFilter) {
        switch value {

        case let dict as DictionaryValue:
            dict.forEach { (key, value) in
                if filter.groupAllowed, filter.validate(key: key), isGroup(value: value) {
                    paths.append(readingPath.appending(key))
                }

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(key))
                explorer.collectKeysPaths(in: &paths, filter: filter)
            }

        case let array as ArrayValue:
            array.enumerated().forEach { (index, value) in
                if filter.groupAllowed, isGroup(value: value), filter.validate(index: index) {
                    paths.append(readingPath.appending(index))
                }

                let explorer = PathExplorerSerialization(value: value, path: readingPath.appending(index))
                explorer.collectKeysPaths(in: &paths, filter: filter)
            }

        default:
            guard filter.singleAllowed else { break }
            guard let name = readingPath.lastKeyElementName else {
                paths.append(readingPath)
                return
            }
            guard filter.validate(key: name) else { break }
            paths.append(readingPath)
        }
    }
}
