//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathTests: XCTestCase {

    // MARK: - Key and index

    func testSimpleKeys() throws {
        try test(
            pathString: "firstKey.secondKey.thirdKey",
            expected: "firstKey", "secondKey", "thirdKey"
        )
    }

    func testKeysWithIndex() throws {
        try test(
            pathString: "firstKey.secondKey[1].thirdKey",
            expected: "firstKey", "secondKey", 1, "thirdKey"
        )
    }

    func testKeysWithNegativeIndex() throws {
        try test(
            pathString: "firstKey.secondKey[-1].thirdKey",
            expected: "firstKey", "secondKey", -1, "thirdKey"
        )
    }

    func testKeysWithBrackets() throws {
        try test(
            pathString: "firstKey.secondKey[1].(third.Key)",
            expected: "firstKey", "secondKey", 1, "third.Key"
        )
    }

    func testKeysWithBracketsAndIndex() throws {
        try test(
            pathString: "firstKey.(second.key)[1].thirdKey",
            expected: "firstKey", "second.key", 1, "thirdKey"
        )
    }

    func testNestedArray() throws {
        try test(
            pathString: "firstKey.secondKey[1][0].thirdKey",
            expected: "firstKey", "secondKey", 1, 0, "thirdKey"
        )
    }

    func testNestedArrayTwoLevels() throws {
        try test(
            pathString: "firstKey.secondKey[1][0][2].thirdKey",
            expected: "firstKey", "secondKey", 1, 0, 2, "thirdKey"
        )
    }

    // MARK: - Alternative separator

    func testSeparator1() throws {
        try test(
            pathString: "firstKey->secondKey->thirdKey",
            separator: "->",
            expected: "firstKey", "secondKey", "thirdKey"
        )
    }

    func testSeparator2() throws {
        try test(
            pathString: "firstKey/secondKey/thirdKey",
            separator: "/",
            expected: "firstKey", "secondKey", "thirdKey"
        )
    }

    func testSeparator3() throws {
        try test(
            pathString: "firstKey$secondKey$thirdKey",
            separator: "$",
            expected: "firstKey", "secondKey", "thirdKey"
        )
    }

    func testInvalidSeparator() throws {
        XCTAssertThrowsError(try Path(string: "", separator: "["))
    }

    func testSeparator3WithBracketAndIndex() throws {
        try test(
            pathString: "firstKey$(second$key)[1]$thirdKey",
            separator: "$",
            expected: "firstKey", "second$key", 1, "thirdKey"
        )
    }

    // MARK: - Root array

    func testRootElementArray() throws {
        try test(
            pathString: "[1].firstKey.secondKey",
            expected: 1, "firstKey", "secondKey"
        )
    }

    func testRootElementNestedArrays() throws {
        try test(
            pathString: "[1][0].firstKey.secondKey",
            expected: 1, 0, "firstKey", "secondKey"
        )
    }

    // MARK: Count

    func testCount() throws {
        try test(
            pathString: "secondKey[#]",
            expected: "secondKey", .count
        )
    }

    func testCountNotFinal() throws {
        try test(
            pathString: "thirdKey[#].secondKey",
            expected: "thirdKey", .count, "secondKey"
        )
    }

    // MARK: - Keys list

    func testKeysList() throws {
        try test(
            pathString: "secondKey[#]",
            expected: "secondKey", .count
        )
    }

    func testKeysListFirstElement() throws {
        try test(
            pathString: "{#}[1]",
            expected: .keysList, 1
        )
    }

    func testKeysListAfterIndex() throws {
        try test(
            pathString: "hello[1]{#}",
            expected: "hello", 1, .keysList
        )
    }

    // MARK: Slice

    func testFullSlice() throws {
        try test(
            pathString: "secondKey[2:4]",
            expected: "secondKey", .slice(2, 4)
        )
    }

    func testPartialSliceLeft() throws {
        try test(
            pathString: "secondKey[:4]",
            expected: "secondKey", .slice(.first, 4)
        )
    }

    func testPartialSliceRight() throws {
        try test(
            pathString: "secondKey[1:]",
            expected: "secondKey", .slice(1, .last)
        )
    }

    // MARK: Filter

    func testFilter() throws {
        try test(
            pathString: "secondKey.#Halo.*#",
            expected: "secondKey", .filter("Halo.*")
        )
    }

    func testFilterAndCount() throws {
        try test(
            pathString: "secondKey.#Halo.*#[#]",
            expected: "secondKey", .filter("Halo.*"), .count
        )
    }
}

extension PathTests {

    func test(
        pathString: String,
        separator: String = ".",
        expected: PathElement...,
        file: StaticString = #file,
        line: UInt = #line) throws {

        try XCTAssertEqual(Path(string: pathString, separator: separator), Path(elements: expected), file: file, line: line)
    }
}
