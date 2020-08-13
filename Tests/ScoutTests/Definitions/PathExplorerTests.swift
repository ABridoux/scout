//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathExplorerTests: XCTestCase {

    // MARK: - Constants

    let pathExplorer = PathExplorerXML(value: "")

    // MARK: - Functions

    func testConvertAutomaticBool() throws {
        let bool = try pathExplorer.convert("true", to: .automatic)

        XCTAssertNotNil(bool as? Bool)
    }

    func testConvertBoolAutomaticBool() throws {
        let bool = try pathExplorer.convert(true, to: .automatic)

        XCTAssertNotNil(bool as? Bool)
    }

    func testConvertAutomaticInt() throws {
        let int = try pathExplorer.convert("1", to: .automatic)

        XCTAssertNotNil(int as? Int)
    }

    func testConvertIntAutomaticInt() throws {
        let int = try pathExplorer.convert(1, to: .automatic)

        XCTAssertNotNil(int as? Int)
    }

    func testConvertAutomaticReal() throws {
        let double = try pathExplorer.convert("1.0", to: .automatic)

        XCTAssertNotNil(double as? Double)
    }

    func testConvertRealAutomaticReal() throws {
        let double = try pathExplorer.convert(1.0, to: .automatic)

        XCTAssertNotNil(double as? Double)
    }

    func testConvertAutomaticString() throws {
        let string = try pathExplorer.convert("hello", to: .automatic)

        XCTAssertNotNil(string as? String)
    }

    func testConvertStringToInt() {
        XCTAssertNoThrow(try pathExplorer.convert("1", to: .int))
    }

    func testConvertIntToInt() {
        XCTAssertNoThrow(try pathExplorer.convert(1, to: .int))
    }

    func testConvertStringToReal() {
        XCTAssertNoThrow(try pathExplorer.convert("1.0", to: .real))
    }

    func testConvertRealToReal() {
        XCTAssertNoThrow(try pathExplorer.convert(1.0, to: .real))
    }

    func testConvertStringToBool() {
        XCTAssertNoThrow(try pathExplorer.convert("false", to: .bool))
    }

    func testConvertBoolToBool() {
        XCTAssertNoThrow(try pathExplorer.convert(true, to: .bool))
    }
}
