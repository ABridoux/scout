//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Lower and upper bounds to be used to slice an array
public struct Bounds: Hashable {

    // MARK: - Properties

    /// Use the `range(lastValidIndex:path)` function to access to the lower bound
    private let lower: Bound

    /// Use the `range(lastValidIndex:path)` function to access to the upper bound
    private let upper: Bound

    @IntWrapper
    private(set) var lastComputedLower

    @IntWrapper
    private(set) var lastComputedUpper

    /// Description of the lower bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(arrayCount:path)` function to access to the lower bound
    var lowerString: String { lower == .first ? "" : String(lower.value) }

    /// Description of the upper bound.
    /// - note: Do not use this value to convert it to an Int. Rather use the `range(arrayCount:path)` function to access to the upper bound
    var upperString: String { upper == .last ? "" : String(upper.value) }

    // MARK: - Initialization

    public init(lower: Bound, upper: Bound) {
        self.lower = lower
        self.upper = upper
    }

    // MARK: - Functions

    /// - Parameters:
    ///   - arrayCount: The count of the array to slice
    ///   - path: Path where the bounds is specified. Used to throw a relevant error
    /// - Throws: If the bounds are invalid
    /// - Returns: A range made from the lower and upper bounds
    public func range(arrayCount: Int, path: Path) throws -> ClosedRange<Int> {
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
            throw PathExplorerError.wrongBounds(self, in: path, arrayCount: arrayCount)
        }

        lastComputedLower = lower
        lastComputedUpper = upper

        return lower...upper
    }

    /// - Parameters:
    ///   - arrayCount: The count of the array to slice
    ///   - path: Path where the bounds is specified. Used to throw a relevant error
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

public extension Bounds {

    struct Bound: ExpressibleByIntegerLiteral, Hashable {
        public typealias IntegerLiteralType = Int
        public static let first = Bound(0, identifier: "first")
        public static let last = Bound(-1, identifier: "last")

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

extension Bounds {

    /// Wrapper aound an `Int` value to avoid to make all the `Bounds` mutable
    /// - note: `Bounds` will only mutate those `IntWrapper` values internally
    @propertyWrapper
    final class IntWrapper: Hashable {

        fileprivate(set) var wrappedValue: Int?

        static func == (lhs: IntWrapper, rhs: IntWrapper) -> Bool {
            lhs.wrappedValue == rhs.wrappedValue
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(wrappedValue)
        }
    }
}
