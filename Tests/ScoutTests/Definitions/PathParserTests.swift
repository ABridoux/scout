//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathParserTests: XCTestCase {

    func testKey() {
        test(
            parser: Path.keyParser(separator: "."),
            on: "firstKey.secondKey",
            expected: "firstKey"
        )
    }

    func testIndex() {
        test(
            parser: Path.indexParser,
            on: "[10]",
            expected: 10
        )
    }

    func testIndex_Negative() {
        test(
            parser: Path.indexParser,
            on: "[-10]",
            expected: -10
        )
    }

    func testIndex_Positive() {
        test(
            parser: Path.indexParser,
            on: "[+10]",
            expected: 10
        )
    }

    func testSlice_Full() {
        test(
            parser: Path.sliceParser,
            on: "[2:13]",
            expected: .slice(2, 13)
        )
    }

    func testSlice_NoLeft() {
        test(
            parser: Path.sliceParser,
            on: "[:13]",
            expected: .slice(.first, 13)
        )
    }

    func testSlice_NoRight() {
        test(
            parser: Path.sliceParser,
            on: "[2:]",
            expected: .slice(2, .last)
        )
    }

    func testSlice_NoLeftNoRight() {
        test(
            parser: Path.sliceParser,
            on: "[:]",
            expected: .slice(.first, .last)
        )
    }

    func testFilter() {
        test(
            parser: Path.filterParser,
            on: "#Toto|Endo#",
            expected: .filter("Toto|Endo")
        )
    }

    func testStringNotContains1() {
        let parser = PathParsers.string(stoppingAt: "Toto")

        let result = parser.run("Hello Toto!")

        XCTAssertEqual(result?.0, "Hello ")
        XCTAssertEqual(result?.1, "Toto!")
    }

    func testStringNotContains2() {
        let parser = PathParsers.string(stoppingAt: "Toto")

        let result = parser.run("I think Toto is overrated")

        XCTAssertEqual(result?.0, "I think ")
    }

    func testStringNotContains_Nil() {
        let parser = PathParsers.string(stoppingAt: "Toto")

        let result = parser.run("Toto is a stub name")

        XCTAssertNil(result)
    }

    func testStringNotContains_ForbiddenCharacter() {
        let parser = PathParsers.string(stoppingAt: "Toto", forbiddenCharacters: ",")

        let result = parser.run("Hello, Toto!")

        XCTAssertEqual(result?.0, "Hello")
        XCTAssertEqual(result?.1, ", Toto!")
    }
}

extension PathParserTests {

    func test(
        parser: PathParser<PathElement>,
        on string: String,
        expected: PathElement,
        file: StaticString = #file,
        line: UInt = #line) {
        let result = parser.run(string)

        XCTAssertEqual(result?.0, expected, file: file, line: line)
    }
}
