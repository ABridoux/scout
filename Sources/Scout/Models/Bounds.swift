//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Lower and upper bounds to be used to slice an array
public struct Bounds: Equatable {

    // MARK: - Properties

    public let lower: Int
    public let upper: Int

    // MARK: - Initialization

    public init(lower: Int, upper: Int) {
        self.lower = lower
        self.upper = upper
    }

    // MARK: - Functions

    /// - Parameters:
    ///   - lastValidIndex: The last valid index in the array being sliced
    ///   - path: Path where the bounds a specified. Used to throw a relevant error
    /// - Throws: If the bounds are invalid
    /// - Returns: A range made from the lower and upper bounds
    public func range(lastValidIndex: Int, path: Path) throws -> ClosedRange<Int> {
        guard
            lower >= 0, upper <= lastValidIndex,
            (lower < upper || lower < lastValidIndex && upper == .lastIndex)
        else {
                throw PathExplorerError.wrongBounds(self, in: path)
        }

        // transform .maxIndex into the array last index
        let upper = self.upper == .lastIndex ? lastValidIndex : self.upper
        return lower...upper
    }
}
