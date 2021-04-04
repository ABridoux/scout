//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ValueType {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        var paths: [Path] = []

        if let path = initialPath {
            let explorer = try get(path)
            try explorer.collectPaths(in: &paths, filter: filter, leadingPath: path, lastKey: nil)
        } else {
            try collectPaths(in: &paths, filter: filter, leadingPath: .empty, lastKey: nil)
        }

        return paths.lazy.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    /// Explorer self and add the relevant paths to the array
    /// - Parameters:
    ///   - paths: Array of paths where to add paths
    ///   - filter: A filter allowing to filter the path
    ///   - leadingPath: The starting path leading to the explorer
    ///   - lastKey: The last encountered key element value
    private func collectPaths(in paths: inout [Path], filter: PathsFilter, leadingPath: Path, lastKey: String?) throws {
        switch self {
        case .int, .double, .bool, .data, .string:
            guard filter.singleAllowed, !leadingPath.isEmpty else { return }

            if let lastKey = lastKey, filter.validate(key: lastKey), try filter.validate(value: any) {
                paths.append(leadingPath)
            }

        case .array(let array), .slice(let array):
            if filter.groupAllowed, !leadingPath.isEmpty {
                if let lastKey = lastKey, filter.validate(key: lastKey) {
                    paths.append(leadingPath)
                }
            }
            try array.enumerated().forEach { (index, element) in try element.collectPaths(in: &paths, filter: filter, leadingPath: leadingPath.appending(index), lastKey: lastKey) }

        case .dictionary(let dict), .filter(let dict):
            if filter.groupAllowed, !leadingPath.isEmpty {
                if let lastKey = lastKey, filter.validate(key: lastKey) {
                    paths.append(leadingPath)
                }
            }
            try dict.forEach { try $0.value.collectPaths(in: &paths, filter: filter, leadingPath: leadingPath.appending($0.key), lastKey: $0.key) }

        case .count:
            throw ValueTypeError.wrongUsage(of: .count)

        case .keysList:
            throw ValueTypeError.wrongUsage(of: .keysList)
        }
    }
}
