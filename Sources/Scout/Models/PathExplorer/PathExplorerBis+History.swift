//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorerBis {

    /// Get the provided paths and execute the block for each of them.
    ///
    /// The discovered explorer will be kept for the next path when paths have a common prefix.
    /// Thus this function works better when the array of paths is sorted
    /// - Parameters:
    ///   - paths: The paths to get
    ///   - block: The block to execute with the explorer retrieved for the path
    func explore(paths: [Path], using block: (Result<Self, ExplorerError>) throws -> Void) rethrows {
        let history = History(origin: self)
        try paths.forEach { try  history.explore(path: $0, using: block) }
    }

    func exploreReduce<T>(initial: T, paths: [Path], using transform: (_ result: T, _ explorer: Result<Self, ExplorerError>) throws -> T) rethrows -> T {
        var result = initial
        try explore(paths: paths) { (explorer) in
            result = try transform(result, explorer)
        }
        return result
    }
}

private final class History<Explorer: PathExplorerBis> {
    let origin: Explorer
    private(set) var lastExploredPath: Slice<Path> = Slice(Path.empty)
    private(set) var lastExplorers: ArraySlice<Explorer> = []
    private var lastExplorer: Explorer { lastExplorers.last ?? origin }

    init(origin: Explorer) {
        self.origin = origin
    }

    func explore(path: Path, using exploringHandler: (Result<Explorer, ExplorerError>) throws -> Void) rethrows {
        // explorer only the difference
        let differenceToExplore = suffixDifference(with: path)
        var currentExplorer = lastExplorer

        for element in differenceToExplore {
            let nextExplorer: Explorer

            do {
                 nextExplorer = try currentExplorer.get(element)
            } catch let error as ExplorerError {
                try exploringHandler(.failure(error))
                return
            } catch {
                assertionFailure("The explorer should throw an explorer error")
                return
            }

            lastExploredPath.append(element)
            lastExplorers.append(nextExplorer)
            currentExplorer = nextExplorer
        }

        try exploringHandler(.success(currentExplorer))
    }

    private func suffixDifference(with path: Path) -> Slice<Path> {
        let commonPrefix = lastExploredPath.commonPrefix(with: Slice(path))

        // drop the suffix difference in the last explored path
        let commonPrefixRange = commonPrefix.startIndex..<commonPrefix.endIndex
        lastExploredPath = lastExploredPath[commonPrefixRange]
        lastExplorers = lastExplorers[commonPrefixRange]

        // return the difference
        return path[commonPrefix.endIndex..<path.endIndex]
    }
}
