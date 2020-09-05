//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class StringExtensionsTests: XCTestCase {

    func testEscape1() {
        let string = "Hello, there"
        XCTAssertEqual(#""Hello, there""#, string.escapingCSV(","))
    }
}
