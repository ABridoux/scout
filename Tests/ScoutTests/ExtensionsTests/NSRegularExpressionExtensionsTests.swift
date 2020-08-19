//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class NSRegularExpressionExtensionsTests: XCTestCase {

    func testValidate1() throws {
        let pattern = "[0-9]+"
        let regex = try NSRegularExpression(pattern: pattern)

        XCTAssertTrue(regex.validate("1234"))
        XCTAssertFalse(regex.validate("123A4"))
    }

    func testValidate2() throws {
        let pattern = #"[a-zA-Z]+\s+[0-9]+"#
        let regex = try NSRegularExpression(pattern: pattern)

        XCTAssertTrue(regex.validate("John 117"))
        XCTAssertFalse(regex.validate("Arbiter"))
    }
}
