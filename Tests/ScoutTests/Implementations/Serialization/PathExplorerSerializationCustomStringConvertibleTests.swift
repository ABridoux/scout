//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class PathExplorerSerializationCustomStringConvertibleTests: XCTestCase {

    func testBool() {
        let explorer: Json = true

        XCTAssertEqual(explorer.description, "true")
    }

    func testString() {
        let explorer: Json = "Hello"

        XCTAssertEqual(explorer.description, "Hello")
    }

    func testInt() {
        let explorer: Json = 2

        XCTAssertEqual(explorer.description, "2")
    }

    func testDouble() {
        let explorer: Json = 3.5

        XCTAssertEqual(explorer.description, "3.5")
    }
}
