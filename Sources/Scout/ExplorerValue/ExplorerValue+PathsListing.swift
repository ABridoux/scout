//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerValue {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        var paths: [Path] = []

        if let path = initialPath {
            let explorer = try get(path)
            try explorer.collectPaths(in: &paths, filter: filter, pathValidation: PathValidation(leading: path, filter: filter))
        } else {
            try collectPaths(in: &paths, filter: filter, pathValidation: PathValidation(leading: .empty, filter: filter))
        }

        return paths.map { $0.flattened() }
    }

    /// Explorer self and add the relevant paths to the array
    /// - Parameters:
    ///   - paths: Array of paths where to add paths
    ///   - filter: A filter allowing to filter the path
    ///   - leadingPath: The starting path leading to the explorer
    ///   - lastKey: The last encountered key element value
    private func collectPaths(in paths: inout [Path], filter: PathsFilter, pathValidation: PathValidation) throws {
        switch self {
        case .int, .double, .bool, .data, .string:
            guard filter.singleAllowed, pathValidation.isValid else { return }

            if try filter.validate(value: self) {
                paths.append(pathValidation.leading)
            }

        case .array(let array):
            if filter.groupAllowed, pathValidation.isValid {
                paths.append(pathValidation.leading)
            }

            try array.enumerated()
                .forEach { (index, element) in
                    try element.collectPaths(in: &paths, filter: filter, pathValidation: pathValidation.appendingLeading(index))
                }

        case .dictionary(let dict):
            if filter.groupAllowed, pathValidation.isValid {
                paths.append(pathValidation.leading)
            }

            try dict.forEach { (key, value) in
                try value.collectPaths( in: &paths, filter: filter, pathValidation: pathValidation.appendingLeading(key))
            }
        }
    }
}

extension ExplorerValue {

    /// Holds the logic to validate a path built during paths listing
    private struct PathValidation {
        let filter: PathsFilter
        private(set) var leading: Path
        private var isInitial = true
        private var hasOneKeyValidated = false

        /// `true` when the leading path can be added, depending on the filter and the initial path
        var isValid: Bool { !isInitial && hasOneKeyValidated }

        init(leading: Path, filter: PathsFilter) {
            self.leading = leading
            self.filter = filter

            hasOneKeyValidated = leading.lazy
                .compactMap(\.key)
                .contains { filter.validate(key: $0) }
        }

        func appendingLeading(_ element: PathElementRepresentable) -> PathValidation {
            var copy = self
            copy.leading = leading.appending(element)
            copy.isInitial = false

            if let key = element.pathValue.key, filter.validate(key: key) {
                copy.hasOneKeyValidated = true
            }
            return copy
        }
    }
}
