//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ValueType {

    /// Compute the index, positive or negative. Negative index uses the array count
    /// - Parameters:
    ///   - index: Index to compute
    ///   - arrayCount: Array count
    func computeIndex(from index: Int, arrayCount: Int) throws -> Int {
        let computedIndex = index < 0 ? arrayCount + index : index

        guard 0 <= computedIndex, computedIndex < arrayCount else {
            throw ValueTypeError.wrong(index: index, arrayCount: arrayCount)
        }

        return computedIndex
    }
}
