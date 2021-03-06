//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class PathExplorerSerializationValueConversionTests: XCTestCase {

    func testGetBool() {
        let explorer: Json = true

        XCTAssertEqual(explorer.bool, true)
    }

    func testGetInt() {
        let explorer: Json = 2

        XCTAssertEqual(explorer.int, 2)
    }

    func testGetDouble() {
        let explorer: Json = 3.5

        XCTAssertEqual(explorer.double, 3.5)
    }

    func testGetString() {
        let explorer: Json = "Hi"

        XCTAssertEqual(explorer.string, "Hi")
    }

    func testGetArrayString() {
        let array = ["Hi", "friend"]
        let explorer = Json(value: array)

        XCTAssertEqual(explorer.array(.string), array)
    }

    func testGetDictDouble() {
        let dict = ["Donald": 20, "Daisy": 30]
        let explorer = Json(value: dict)

        XCTAssertEqual(explorer.dictionary(.int), dict)
    }

    func testGetNestedArrayNil() {
        let array: [Any] = ["Hi", ["friends"]]
        let explorer = Json(value: array)

        XCTAssertNil(explorer.array(.any))
    }

    func testGetNestedDictNil() {
        let dict: Any = ["Donald": 20, "Daisy": [30, 40]]
        let explorer = Json(value: dict)

        XCTAssertNil(explorer.dictionary(.any))
    }

    // MARK: Description

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
