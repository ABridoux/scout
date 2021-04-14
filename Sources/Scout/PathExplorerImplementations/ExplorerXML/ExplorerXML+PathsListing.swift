//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        var paths: [Path] = []

        if let initialPath = initialPath {
            if let first = initialPath.first(where: { [.count, .keysList].contains($0) }) {
                throw ExplorerError.wrongUsage(of: first)
            }
            let explorer = try getNoDetailedName(initialPath)
            try explorer.collectPaths(in: &paths, filter: filter, pathValidation: PathValidation(leading: initialPath, filter: filter))
        } else {
            try collectPaths(in: &paths, filter: filter, pathValidation: PathValidation(leading: .empty, filter: filter))
        }

        return paths.map { $0.flattened() }.sortedByKeysAndIndexes()
    }

    private func collectPaths(in paths: inout [Path], filter: PathsFilter, pathValidation: PathValidation) throws {
        if pathValidation.isValid {
            if filter.singleAllowed, children.isEmpty, try filter.validate(value: valueAsAny) {
                paths.append(pathValidation.leading)
            }

            if filter.groupAllowed, !children.isEmpty, filter.validate(key: name) {
                paths.append(pathValidation.leading)
            }
        }

        if differentiableChildren {
            try children
                .forEach { try $0.collectPaths(in: &paths, filter: filter, pathValidation: pathValidation.appendingLeading($0.name)) }
        } else {
            try children.enumerated()
                .forEach { try $1.collectPaths(in: &paths, filter: filter, pathValidation: pathValidation.appendingLeading($0)) }
        }
    }
}

extension ExplorerXML {

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
