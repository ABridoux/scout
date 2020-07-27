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
    let secondKeyWithdot = "second.key"
    let secondKeyWithDotAndIndex = "second.key[1]"
    let secondKeyWithFourthSeparator = "second$key"
    let secondKeyWithNestedArray = "secondKey[1][0]"
    let secondKeyWithTwoNestedArrays = "secondKey[1][0][2]"
    let secondKeyWithFourthSeparatorAndIndex = "second$key[1]"
    let secondKeyWithCount = "secondKey[#]"
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
        let array: Path = [firstKey, secondKeyWithdot, 1, thirdKey]
        let path = try Path(string: "\(firstKey).(\(secondKeyWithDotAndIndex)).\(thirdKey)")

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
        let path = try Path(string: "\(firstKey)$(\(secondKeyWithFourthSeparatorAndIndex))$\(thirdKey)", separator: fourthSeparator)

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
}
