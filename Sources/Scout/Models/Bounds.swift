//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Lower and upper bounds to be used to slice an array
public struct Bounds: Equatable {

    // MARK: - Properties

    /// Use the `range(lastValidIndex:path)` function to access to the lower bound
    private let lower: Int
    /// Use the `range(lastValidIndex:path)` function to access to the upper bound
    private let upper: Int

    /// Description of the lower bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(lastValidIndex:path)` function to access to the lower bound
    var lowerString: String { lower == 0 ? "" : String(lower) }

    /// Description of the upper bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(lastValidIndex:path)` function to access to the upper bound
    var upperString: String { (upper == .lastIndex || upper == .lastNegativeIndex) ? "" : String(upper) }

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
        let lower = self.lower < 0 ? lastValidIndex + self.lower + 1 : self.lower

        let upper: Int
        if self.lower < 0 && self.upper <= 0 { // deal with negative indexes
            upper = lastValidIndex + self.upper
        } else if self.upper == .lastIndex {
            upper = lastValidIndex
        } else {
            upper = self.upper
        }

        guard 0 <= lower, lower < upper, upper <= lastValidIndex else {
            throw PathExplorerError.wrongBounds(self, in: path, lastValidIndex: lastValidIndex)
        }
        return lower...upper
    }
}
