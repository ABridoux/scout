//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class PathRegularExpressionTests: XCTestCase {

    func testLastKeyRegexSimple() throws {
        let path = Path("ducks", "age")
        let ageRegex = try NSRegularExpression(pattern: "age")
        let ducksRegex = try NSRegularExpression(pattern: "ducks")

        XCTAssertTrue(path.lastKeyComponent(matches: ageRegex))
        XCTAssertFalse(path.lastKeyComponent(matches: ducksRegex))
    }

    func testLastKeyRegexComplex() throws {
        let path = Path("ducks", "age", "mouses", 2)
        let correctRegex = try NSRegularExpression(pattern: ".*mo.*")
        let wrongRegex = try NSRegularExpression(pattern: ".*mo[0-9]{1}.*")

        XCTAssertTrue(path.lastKeyComponent(matches: correctRegex))
        XCTAssertFalse(path.lastKeyComponent(matches: wrongRegex))
    }
}
