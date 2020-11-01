//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Lower and upper bounds to be used to slice an array
public struct Bounds: Equatable {

    // MARK: - Properties

    /// Use the `range(lastValidIndex:path)` function to access to the lower bound
    private let lower: Bound

    /// Use the `range(lastValidIndex:path)` function to access to the upper bound
    private let upper: Bound

    /// Description of the lower bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(lastValidIndex:path)` function to access to the lower bound
    var lowerString: String { lower == .first ? "" : String(lower.value) }

    /// Description of the upper bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(lastValidIndex:path)` function to access to the upper bound
    var upperString: String { upper == .last ? "" : String(upper.value) }

    // MARK: - Initialization

    public init(lower: Bound, upper: Bound) {
        self.lower = lower
        self.upper = upper
    }

    // MARK: - Functions

    /// - Parameters:
    ///   - lastValidIndex: The last valid index in the array being sliced
    ///   - path: Path where the bounds is specified. Used to throw a relevant error
    /// - Throws: If the bounds are invalid
    /// - Returns: A range made from the lower and upper bounds
    public func range(lastValidIndex: Int, path: Path) throws -> ClosedRange<Int> {
        let lower = self.lower.value < 0 ? lastValidIndex + self.lower.value : self.lower.value

        let upper: Int
        if self.upper == .last {
            upper = lastValidIndex
        } else if self.upper.value < 0 { // deal with negative indexes
            upper = lastValidIndex + self.upper.value
        } else {
            upper = self.upper.value
        }

        guard 0 <= lower, lower <= upper, upper <= lastValidIndex else {
            throw PathExplorerError.wrongBounds(self, in: path, lastValidIndex: lastValidIndex)
        }
        return lower...upper
    }
}

public extension Bounds {

    struct Bound: ExpressibleByIntegerLiteral, Equatable {
        public typealias IntegerLiteralType = Int
        public static let first = Bound(0, identifier: "first")
        public static let last = Bound(0, identifier: "last")

        var value: Int
        private(set) var identifier: String?

        public init(integerLiteral value: Int) {
            self.value = value
        }

        public init(_ value: Int) {
            self.value = value
        }

        private init(_ value: Int, identifier: String) {
            self.value = value
            self.identifier = identifier
        }
    }
}
