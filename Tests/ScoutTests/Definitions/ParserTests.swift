//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Parsing
@testable import Scout
import XCTest

final class ParserTests: XCTestCase {

    typealias ElementParsers = Path.ElementParsers

    func testKey() {
        test(
            parser: ElementParsers.key(separator: ".", forbiddenCharacters: []),
            on: "firstKey.secondKey",
            expected: "firstKey"
        )
    }

    func testIndex() {
        test(
            parser: ElementParsers.index,
            on: "[10]",
            expected: 10
        )
    }

    func testIndex_Negative() {
        test(
            parser: ElementParsers.index,
            on: "[-10]",
            expected: -10
        )
    }

    func testIndex_Positive() {
        test(
            parser: ElementParsers.index,
            on: "[+10]",
            expected: 10
        )
    }

    func testSlice_Full() {
        test(
            parser: ElementParsers.slice,
            on: "[2:13]",
            expected: .slice(2, 13)
        )
    }

    func testSlice_NoLeft() {
        test(
            parser: ElementParsers.slice,
            on: "[:13]",
            expected: .slice(.first, 13)
        )
    }

    func testSlice_NoRight() {
        test(
            parser: ElementParsers.slice,
            on: "[2:]",
            expected: .slice(2, .last)
        )
    }

    func testSlice_NoLeftNoRight() {
        test(
            parser: ElementParsers.slice,
            on: "[:]",
            expected: .slice(.first, .last)
        )
    }

    func testFilter() {
        test(
            parser: ElementParsers.filter,
            on: "#Toto|Endo#",
            expected: .filter("Toto|Endo")
        )
    }

    func testStringNotContains1() {
        let parser = Parsers.string(stoppingAt: "Toto")

        let result = parser.run("Hello Toto!")

        XCTAssertEqual(result?.result, "Hello ")
        XCTAssertEqual(result?.remainder, "Toto!")
    }

    func testStringNotContains2() {
        let parser = Parsers.string(stoppingAt: "Toto")

        let result = parser.run("I think Toto is overrated")

        XCTAssertEqual(result?.result, "I think ")
    }

    func testStringNotContains_Nil() {
        let parser = Parsers.string(stoppingAt: "Toto")

        let result = parser.run("Toto is a stub name")

        XCTAssertNil(result)
    }

    func testStringNotContains_ForbiddenCharacter() {
        let parser = Parsers.string(stoppingAt: "Toto", forbiddenCharacters: ",")

        let result = parser.run("Hello, Toto!")

        XCTAssertEqual(result?.result, "Hello")
        XCTAssertEqual(result?.remainder, ", Toto!")
    }
}

extension ParserTests {

    func test(
        parser: Parser<PathElement>,
        on string: String,
        expected: PathElement,
        file: StaticString = #file,
        line: UInt = #line) {
        let result = parser.run(string)

        XCTAssertEqual(result?.0, expected, file: file, line: line)
    }
}
