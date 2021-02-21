//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathTests: XCTestCase {

    // MARK: - Constants

    let firstKey = "firstKey"
    let secondKey = "secondKey"
    let index = 1
    let secondKeyWithIndex = "secondKey[1]"
    let secondKeyWithNegativeIndex = "secondKey[-1]"
    let secondKeyWithDot = "second.key"
    let secondKeyWithDotAndIndex = "second.key[1]"
    let secondKeyWithFourthSeparator = "second$key"
    let secondKeyWithNestedArray = "secondKey[1][0]"
    let secondKeyWithTwoNestedArrays = "secondKey[1][0][2]"
    let secondKeyWithCount = "secondKey[#]"
    let secondKeyWithKeysList = "secondKey{#}"
    let secondKeyWithFullRange = "secondKey[2:4]"
    let secondKeyWithPartialRangeLeft = "secondKey[:4]"
    let secondKeyWithPartialRangeRight = "secondKey[1:]"
    let secondKeyWithFilter = "secondKey.#Halo.*#"
    let secondKeyWithFilterAndCount = "secondKey.#Halo.*#[#]"

    let thirdKey = "thirdKey"
    let thirdKeyWithCount = "thirdKey[#].secondKey"
    let thirdKeyWithDot = "third.Key"

    let secondSeparator = "->"
    let thirdSeparator = "\\/"
    let fourthSeparator = "\\$"

    // MARK: - Functions

    func testEqual() throws {
        let path1 = Path(firstKey, secondKey, thirdKey)
        let path2 = Path(firstKey, secondKey, thirdKey)

        XCTAssertEqual(path1, path2)
    }

    func testSimpleKeys() throws {
        let expectedPath = Path(firstKey, secondKey, thirdKey)
        let path = Path(string: "\(firstKey).\(secondKey).\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysWithIndex() throws {
        let expectedPath = Path(firstKey, secondKey, index, thirdKey)
        let path = Path(string: "\(firstKey).\(secondKeyWithIndex).\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysWithNegativeIndex() throws {
        let expectedPath = Path(firstKey, secondKey, -index, thirdKey)
        let path = Path(string: "\(firstKey).\(secondKeyWithNegativeIndex).\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysWithBrackets() throws {
        let expectedPath = Path(firstKey, secondKey, index, thirdKeyWithDot)
        let path = Path(string: "\(firstKey).\(secondKeyWithIndex).(\(thirdKeyWithDot))")

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysWithBracketsAndIndex() throws {
        let expectedPath = Path(firstKey, secondKeyWithDot, 1, thirdKey)
        let path = Path(string: "\(firstKey).(\(secondKeyWithDot))[1]\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testNestedArray() throws {
        let expectedPath = Path(firstKey, secondKey, index, 0, thirdKey)
        let path = Path(string: "\(firstKey).\(secondKeyWithNestedArray).\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testNestedArrayTwoLevels() throws {
        let expectedPath = Path(firstKey, secondKey, index, 0, 2, thirdKey)
        let path = Path(string: "\(firstKey).\(secondKeyWithTwoNestedArrays).\(thirdKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testSeparator1() throws {
        let expectedPath = Path(firstKey, secondKey, thirdKey)
        let path = try Path(string: "\(firstKey)\(secondSeparator)\(secondKey)\(secondSeparator)\(thirdKey)", separator: secondSeparator)

        XCTAssertEqual(path, expectedPath)
    }

    func testSeparator2() throws {
        let expectedPath = Path(firstKey, secondKey, thirdKey)
        let path = try Path(string: "\(firstKey)/\(secondKey)/\(thirdKey)", separator: thirdSeparator)

        XCTAssertEqual(path, expectedPath)
    }

    func testSeparator3() throws {
        let expectedPath = Path(firstKey, secondKey, thirdKey)
        let path = try Path(string: "\(firstKey)$\(secondKey)$\(thirdKey)", separator: fourthSeparator)

        XCTAssertEqual(path, expectedPath)
    }

    func testInvalidSeparator() throws {
        XCTAssertThrowsError(try Path(string: "", separator: "["))
    }

    func testInvalidSeparator2() throws {
        XCTAssertThrowsError(try Path(string: "", separator: "$"))
    }

    func testSeparator3WithBracketAndIndex() throws {
        let array: Path = [firstKey, secondKeyWithFourthSeparator, index, thirdKey]
        let path = try Path(string: "\(firstKey)$(\(secondKeyWithFourthSeparator))[\(index)]$\(thirdKey)", separator: fourthSeparator)

        XCTAssertEqual(path, array)
    }

    func testRootElementArray() throws {
        let expectedPath = Path(1, firstKey, secondKey)
        let path = Path(string: "[1].\(firstKey).\(secondKey)")

        XCTAssertEqual(path, expectedPath)
    }

    func testRootElementNestedArrays() throws {
        let expectedPath = Path(1, 0, firstKey, secondKey)
        let path = Path(string: "[1][0].\(firstKey).\(secondKey)")

        XCTAssertEqual(path, expectedPath)
    }

    // MARK: Count

    func testCount() throws {
        let expectedPath = Path(secondKey, PathElement.count)
        let path = Path(string: secondKeyWithCount)

        XCTAssertEqual(path, expectedPath)
    }

    func testCountNotFinal() throws {
        let expectedPath = Path(thirdKey, PathElement.count, secondKey)
        let path = Path(string: thirdKeyWithCount)

        XCTAssertEqual(path, expectedPath)
    }

    // MARK: - Keys list

    func testKeysList() throws {
        let expectedPath = Path(secondKey, PathElement.keysList)
        let path = Path(string: secondKeyWithKeysList)

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysListFirstElement() throws {
        let expectedPath = Path(elements: .keysList, 1)
        let path = Path(string: "{#}[1]")

        XCTAssertEqual(path, expectedPath)
    }

    func testKeysListAfterIndex() throws {
        let expectedPath = Path(elements: "hello", 1, .keysList)
        let path = Path(string: "hello[1]{#}")

        XCTAssertEqual(path, expectedPath)
    }

    // MARK: Slice

    func testFullSlice() throws {
        let expectedPath = Path(secondKey, PathElement.slice(2, 4))
        let path = Path(string: secondKeyWithFullRange)

        XCTAssertEqual(path, expectedPath)
    }

    func testPartialSliceLeft() throws {
        let array = Path(secondKey, PathElement.slice(.init(lower: .first, upper: 4)))
        let path = Path(string: secondKeyWithPartialRangeLeft)

        XCTAssertEqual(path, array)
    }

    func testPartialSliceRight() throws {
        let array = Path(secondKey, PathElement.slice(1, .last))
        let path = Path(string: secondKeyWithPartialRangeRight)

        XCTAssertEqual(path, array)
    }

    // MARK: Filter

    func testFilter() throws {
        let array = Path(secondKey, PathElement.filter("Halo.*"))
        let path = Path(string: secondKeyWithFilter)

        XCTAssertEqual(path, array)
    }

    func testFilterAndCount() throws {
        let array = Path(secondKey, PathElement.filter("Halo.*"), PathElement.count)
        let path = Path(string: secondKeyWithFilterAndCount)

        XCTAssertEqual(path, array)
    }
}
