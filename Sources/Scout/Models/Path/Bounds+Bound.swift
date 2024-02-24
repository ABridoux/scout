//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - Bound

public extension Bounds {

    struct Bound: ExpressibleByIntegerLiteral, Hashable {

        // MARK: Type alias

        public typealias IntegerLiteralType = Int

        // MARK: Constants

        public static let first = Bound(0, identifier: "first")
        public static let last = Bound(-1, identifier: "last")

        // MARK: Properties

        var value: Int
        private(set) var identifier: String?

        // MARK: Init

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
