//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import ScoutCLTCore
import XCTest
import Parsing

final class ValueParserTest: XCTestCase {

    func testReal() {
        test(
            parser: PathAndValue.ValueParsers.real,
            on: "~25~",
            expected: .real("25")
        )
    }

    func testKeyName() {
        test(
            parser: PathAndValue.ValueParsers.keyName,
            on: "#Toto#",
            expected: .keyName("Toto")
        )
    }

    func testString() {
        test(
            parser: PathAndValue.ValueParsers.string,
            on: "/123/",
            expected: .string("123")
        )
    }

    func testAutomatic() {
        test(
            parser: PathAndValue.ValueParsers.automatic,
            on: "123",
            expected: .automatic("123")
        )
    }
}

extension ValueParserTest {

    func test(
        parser: Parser<ValueType>,
        on string: String,
        expected: ValueType,
        file: StaticString = #file,
        line: UInt = #line) {
        let result = parser.run(string)

        XCTAssertEqual(result?.0, expected, file: file, line: line)
    }
}
