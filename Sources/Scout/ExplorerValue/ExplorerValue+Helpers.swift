//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorer {

    /// Compute the index, positive or negative. Negative index uses the array count.
    /// - Parameters:
    ///   - index: Index to compute
    ///   - arrayCount: Array count
    func computeIndex(from index: Int, arrayCount: Int) throws -> Int {
        let computedIndex = index < 0 ? arrayCount + index : index

        if computedIndex == 0 && arrayCount == 0 { return 0 }

        guard 0 <= computedIndex, computedIndex < arrayCount else {
            throw ExplorerError.wrong(index: index, arrayCount: arrayCount)
        }

        return computedIndex
    }
}
