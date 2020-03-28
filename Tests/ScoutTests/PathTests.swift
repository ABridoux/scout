import XCTest
@testable import Scout

final class PathTests: XCTestCase {

    // MARK: - Constants

    let firstKey = "firstKey"
    let secondKey = "secondKey"
    let secondKeyWithIndex = "secondKey[1]"
    let secondKeyWithNegativeIndex = "secondKey[-1]"
    let secondKeyWithdot = "second.key"
    let secondKeyWithDotAndIndex = "second.key[1]"
    let secondKeyWithFourthSeparator = "second$key"
    let secondKeyWithNestedArray = "secondKey[1][0]"
    let secondKeyWithTwoNestedArrays = "secondKey[1][0][2]"
    let secondKeyWithFourthSeparatorAndIndex = "second$key[1]"
    let thirdKey = "thirdKey"
    let thirdKeyWithDot = "third.Key"

    let secondSeparator = "->"
    let thirdSeparator = "/"
    let fourthSeparator = "\\$"

    // MARK: - Functions

    func testSimpleKeys() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKey).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testKeysWithIndex() throws {
        let array: Path = [firstKey, secondKey, 1, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithIndex).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testKeysWithNegativeIndex() throws {
        let array: Path = [firstKey, secondKey, -1, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithNegativeIndex).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testKeysWithBrackets() throws {
        let array: Path = [firstKey, secondKey, 1, thirdKeyWithDot]
        let path = try Path(string: "\(firstKey).\(secondKeyWithIndex).(\(thirdKeyWithDot))")

        XCTAssertTrue(path == array)
    }

    func testKeysWithBracketsAndIndex() throws {
        let array: Path = [firstKey, secondKeyWithdot, 1, thirdKey]
        let path = try Path(string: "\(firstKey).(\(secondKeyWithDotAndIndex)).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testNestedArray() throws {
        let array: Path = [firstKey, secondKey, 1, 0, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithNestedArray).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testNestedArrayTwoLevels() throws {
        let array: Path = [firstKey, secondKey, 1, 0, 2, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithTwoNestedArrays).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testSeparator1() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)\(secondSeparator)\(secondKey)\(secondSeparator)\(thirdKey)", separator: secondSeparator)

        XCTAssertTrue(path == array)
    }

    func testSeparator2() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)\(thirdSeparator)\(secondKey)\(thirdSeparator)\(thirdKey)", separator: thirdSeparator)

        XCTAssertTrue(path == array)
    }

    func testSeparator3() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey)$\(secondKey)$\(thirdKey)", separator: fourthSeparator)

        XCTAssertTrue(path == array)
    }

    func testSeparator3WithBracketAndIndex() throws {
        let array: Path = [firstKey, secondKeyWithFourthSeparator, 1, thirdKey]
        let path = try Path(string: "\(firstKey)$(\(secondKeyWithFourthSeparatorAndIndex))$\(thirdKey)", separator: fourthSeparator)

        XCTAssertTrue(path == array)
    }

    func testRootElementArray() throws {
        let array: Path = [1, firstKey, secondKey]
        let path = try Path(string: "[1].\(firstKey).\(secondKey)")

        XCTAssertTrue(path == array)
    }
}
