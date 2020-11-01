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
    let thirdSeparator = "/"
    let fourthSeparator = "\\$"

    // MARK: - Functions

    func testEqual() throws {
        let path1: Path = [firstKey, secondKey, thirdKey]
        let path2: Path = [firstKey, secondKey, thirdKey]

        XCTAssertEqual(path1, path2)
    }

    func testSimpleKeys() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKey).\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testKeysWithIndex() throws {
        let array: Path = [firstKey, secondKey, index, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithIndex).\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testKeysWithNegativeIndex() throws {
        let array: Path = [firstKey, secondKey, -index, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithNegativeIndex).\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testKeysWithBrackets() throws {
        let array: Path = [firstKey, secondKey, index, thirdKeyWithDot]
        let path = try Path(string: "\(firstKey).\(secondKeyWithIndex).(\(thirdKeyWithDot))")

        XCTAssertEqual(path, array)
    }

    func testKeysWithBracketsAndIndex() throws {
        let array: Path = [firstKey, secondKeyWithDot, 1, thirdKey]
        let path = try Path(string: "\(firstKey).(\(secondKeyWithDot))[1]\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testNestedArray() throws {
        let array: Path = [firstKey, secondKey, index, 0, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithNestedArray).\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testNestedArrayTwoLevels() throws {
        let array: Path = [firstKey, secondKey, index, 0, 2, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithTwoNestedArrays).\(thirdKey)")

        XCTAssertEqual(path, array)
    }

    func testSeparator1() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)\(secondSeparator)\(secondKey)\(secondSeparator)\(thirdKey)", separator: secondSeparator)

        XCTAssertEqual(path, array)
    }

    func testSeparator2() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)\(thirdSeparator)\(secondKey)\(thirdSeparator)\(thirdKey)", separator: thirdSeparator)

        XCTAssertEqual(path, array)
    }

    func testSeparator3() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)$\(secondKey)$\(thirdKey)", separator: fourthSeparator)

        XCTAssertEqual(path, array)
    }

    func testSeparator3WithBracketAndIndex() throws {
        let array: Path = [firstKey, secondKeyWithFourthSeparator, index, thirdKey]
        let path = try Path(string: "\(firstKey)$(\(secondKeyWithFourthSeparator))[\(index)]$\(thirdKey)", separator: fourthSeparator)

        XCTAssertEqual(path, array)
    }

    func testRootElementArray() throws {
        let array: Path = [1, firstKey, secondKey]
        let path = try Path(string: "[1].\(firstKey).\(secondKey)")

        XCTAssertEqual(path, array)
    }

    func testRootElementNestedArrays() throws {
        let array: Path = [1, 0, firstKey, secondKey]
        let path = try Path(string: "[1][0].\(firstKey).\(secondKey)")

        XCTAssertEqual(path, array)
    }

    // MARK: Count

    func testCount() throws {
        let array: Path = [secondKey, PathElement.count]
        let path = try Path(string: secondKeyWithCount)

        XCTAssertEqual(path, array)
    }

    func testCountNotFinal() throws {
        let array: Path = [thirdKey, PathElement.count, secondKey]
        let path = try Path(string: thirdKeyWithCount)

        XCTAssertEqual(path, array)
    }

    // MARK: - Keys list

    func testKeysList() throws {
        let array: Path = [secondKey, PathElement.keysList]
        let path = try Path(string: secondKeyWithKeysList)

        XCTAssertEqual(path, array)
    }

    func testKeysListFirstElement() throws {
        let array: Path = [PathElement.keysList, 1]
        let path = try Path(string: "{#}[1]")

        XCTAssertEqual(path, array)
    }

    func testKeysListAfterIndex() throws {
        let array: Path = ["hello", 1, PathElement.keysList]
        let path = try Path(string: "hello[1]{#}")

        XCTAssertEqual(path, array)
    }

    // MARK: Slice

    func testFullSlice() throws {
        let array = Path(secondKey, PathElement.slice(2, 4))
        let path = try Path(string: secondKeyWithFullRange)

        XCTAssertEqual(path, array)
    }

    func testPartialSliceLeft() throws {
        let array = Path(secondKey, PathElement.slice(.init(lower: .first, upper: 4)))
        let path = try Path(string: secondKeyWithPartialRangeLeft)

        XCTAssertEqual(path, array)
    }

    func testPartialSliceRight() throws {
        let array = Path(secondKey, PathElement.slice(1, .last))
        let path = try Path(string: secondKeyWithPartialRangeRight)

        XCTAssertEqual(path, array)
    }

    // MARK: Filter

    func testFilter() throws {
        let array = Path(secondKey, PathElement.filter("Halo.*"))
        let path = try Path(string: secondKeyWithFilter)

        XCTAssertEqual(path, array)
    }

    func testFilterAndCount() throws {
        let array = Path(secondKey, PathElement.filter("Halo.*"), PathElement.count)
        let path = try Path(string: secondKeyWithFilterAndCount)

        XCTAssertEqual(path, array)
    }
}
