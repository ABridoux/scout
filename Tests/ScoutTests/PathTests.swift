import XCTest
@testable import Scout

final class PathTests: XCTestCase {

    // MARK: - Constants

    let firstKey = "firstKey"
    let secondKey = "secondKey"
    let secondKeyWithIndex = "secondKey[1]"
    let secondKeyWithdot = "second.key"
    let secondKeyWithDotAndIndex = "second.key[1]"
    let thirdKey = "thirdKey"
    let thirdKeyWithDot = "third.Key"

    // MARK: - Functions

    func testSimpleKeys() throws {
        let array: Path = [firstKey, secondKey, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKey).\(thirdKey)")

        XCTAssertTrue(path == array)
    }

    func testKeysWithIndexes() throws {
        let array: Path = [firstKey, secondKey, 1, thirdKey]
        let path = try Path(string: "\(firstKey).\(secondKeyWithIndex).\(thirdKey)")

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
}
