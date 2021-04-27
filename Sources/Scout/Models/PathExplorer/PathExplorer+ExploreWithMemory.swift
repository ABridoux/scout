//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorer {

    /// Get the provided paths and execute the block for each of them.
    ///
    /// The discovered explorer will be kept for the next path when paths have a common prefix.
    /// Thus this function works better when the array of paths is sorted
    /// - Parameters:
    ///   - paths: The paths to get
    ///   - block: The block to execute with the explorer retrieved for the path
    func exploreWithMemory(paths: [Path], using block: (Result<Self, ExplorerError>) throws -> Void) rethrows {
        let history = GetMemory(origin: self)
        try paths.forEach { try history.explore(path: $0, using: block) }
    }

    /// Reduce provided paths and execute the block for each of them.
    ///
    /// The discovered explorer will be kept for the next path when paths have a common prefix.
    /// Thus this function works better when the array of paths is sorted
    /// - Parameters:
    ///   - paths: The paths to get
    ///   - block: The block to execute with the explorer retrieved for the path
    func reduceWithMemory<T>(initial: T, paths: [Path], using transform: (_ result: T, _ explorer: Result<Self, ExplorerError>) throws -> T) rethrows -> T {
        var result = initial
        try exploreWithMemory(paths: paths) { (explorer) in
            result = try transform(result, explorer)
        }
        return result
    }
}

private final class GetMemory<Explorer: PathExplorer> {
    let origin: Explorer
    private(set) var lastExploredPath: Slice<Path> = Slice(Path.empty)
    private(set) var lastExplorers: ArraySlice<Explorer> = []
    private var lastExplorer: Explorer { lastExplorers.last ?? origin }

    init(origin: Explorer) {
        self.origin = origin
    }

    func explore(path: Path, using exploringHandler: (Result<Explorer, ExplorerError>) throws -> Void) rethrows {
        // explore only the difference
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
                assertionFailure("The explorer should throw an ExplorerError")
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
