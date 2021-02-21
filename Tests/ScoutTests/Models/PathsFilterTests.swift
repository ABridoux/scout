//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathsFilterTests: XCTestCase {

    func testPredicateMismatchedTypes() throws {
        let predicate = try PathsFilter.ExpressionPredicate(format: "value > 10")

        _ = try predicate.evaluate(with: "yo")

        XCTAssertEqual(predicate.operatorsValueTypes, Set(arrayLiteral: .double))
    }

    func testPredicateMismatchedTypesReturnsFalse() throws {
        let predicate = try PathsFilter.ExpressionPredicate(format: "value > 10")

        XCTAssertFalse(try predicate.evaluate(with: "yo"))
    }

    func testPredicateValueTypes() throws {
        let predicate = try PathsFilter.ExpressionPredicate(format: "!(value hasPrefix 'yo')")

        XCTAssertFalse(try predicate.evaluate(with: 10))
    }
}
