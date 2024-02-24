//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Bounds

/// Lower and upper bounds to be used to slice an array.
///
/// - note: Handles negative indexes.
public struct Bounds: Hashable {

    // MARK: Properties

    /// Use the `range(lastValidIndex:path)` function to access to the lower bound
    private let lower: Bound

    /// Use the `range(lastValidIndex:path)` function to access to the upper bound
    private let upper: Bound

    @IntWrapper
    private(set) var lastComputedLower

    @IntWrapper
    private(set) var lastComputedUpper

    // MARK: Computed

    /// Description of the lower bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(arrayCount:path)` function to access to the lower bound
    var lowerString: String { lower == .first ? "" : String(lower.value) }

    /// Description of the upper bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(arrayCount:path)` function to access to the upper bound
    var upperString: String { upper == .last ? "" : String(upper.value) }

    // MARK: Init

    public init(lower: Bound, upper: Bound) {
        self.lower = lower
        self.upper = upper
    }

    /// No bounds targets the `first` or `last` bound
    init(lower: Int?, upper: Int?) {
        if let lower = lower {
            self.lower = Bound(lower)
        } else {
            self.lower = .first
        }

        if let upper = upper {
            self.upper = Bound(upper)
        } else {
            self.upper = .last
        }
    }
}

// MARK: - Range

extension Bounds {

    /// Compute a range with the bounds for the array count.
    /// - Parameters:
    ///   - arrayCount: The count of the array to slice
    /// - Throws: If the bounds are invalid
    /// - Returns: A range made from the lower and upper bounds
    public func range(arrayCount: Int) throws -> ClosedRange<Int> {
        let lower = self.lower.value < 0 ? arrayCount + self.lower.value : self.lower.value

        let upper: Int
        if self.upper == .last {
            upper = arrayCount - 1
        } else if self.upper.value < 0 { // deal with negative indexes
            upper = arrayCount + self.upper.value
        } else {
            upper = self.upper.value
        }

        guard 0 <= lower, lower <= upper, upper <= arrayCount else {
            throw ExplorerError.wrong(bounds: self, arrayCount: arrayCount)
        }

        lastComputedLower = lower
        lastComputedUpper = upper

        return lower...upper
    }
}
