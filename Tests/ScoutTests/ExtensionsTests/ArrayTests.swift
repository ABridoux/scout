//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class ArrayExtensionsTests: XCTestCase {

    let stubArray = ["Riri", "Fifi", "Loulou", "Scrooge", "Donald", "Daisy"]

    func testDeleteRange1() throws {
        let range = 2...4

        XCTAssertEqual(stubArray.remove(in: range), ["Riri", "Fifi", "Daisy"])
    }

    func testDeleteRange2() throws {
        let range = 2...5

        XCTAssertEqual(stubArray.remove(in: range), ["Riri", "Fifi"])
    }

    func testDeleteRange3() throws {
        let range = 0...3

        XCTAssertEqual(stubArray.remove(in: range), ["Donald", "Daisy"])
    }
}
