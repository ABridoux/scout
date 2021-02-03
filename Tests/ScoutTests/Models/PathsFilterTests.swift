//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathsFilterTests: XCTestCase {

    func testPredicateMismatchedTypes() throws {
        let predicate = try PathsFilter.Predicate(format: "value > 10")

        _ = try predicate.evaluate(with: "yo")

        XCTAssertEqual(predicate.mismatchedTypes, Set(arrayLiteral: .string))
    }

    func testPredicateMismatchedTypesReturnsFalse() throws {
        let predicate = try PathsFilter.Predicate(format: "value > 10")

        XCTAssertFalse(try predicate.evaluate(with: "yo"))
    }
}
