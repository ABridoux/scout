//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerHelpersTest: XCTestCase {

    func testComputeIndex_PositiveIndex() throws {
        let result = try PathExplorers.Json.computeIndex(from: 5, arrayCount: 10)

        XCTAssertEqual(result, 5)
    }

    func testComputeIndex_NegativeIndex() throws {
        let result = try PathExplorers.Json.computeIndex(from: -3, arrayCount: 10)

        XCTAssertEqual(result, 7)
    }

    func testComputeIndex_EmptyArray_PositiveIndexThrows() throws {
        XCTAssertErrorsEqual(try PathExplorers.Json.computeIndex(from: 1, arrayCount: 0),
                             .wrong(index: 1, arrayCount: 0))
    }

    func testComputeIndex_EmptyArray_NegativeIndexThrows() throws {
        XCTAssertErrorsEqual(try PathExplorers.Json.computeIndex(from: -1, arrayCount: 0),
                             .wrong(index: -1, arrayCount: 0))
    }

    func testComputeIndex_EmptyArray_ZeroIndexThrows() throws {
        XCTAssertErrorsEqual(try PathExplorers.Json.computeIndex(from: 0, arrayCount: 0),
                             .wrong(index: 0, arrayCount: 0))
    }

    func testComputeIndex_SingleElementArray_PositiveIndexThrows() throws {
        XCTAssertErrorsEqual(try PathExplorers.Json.computeIndex(from: 1, arrayCount: 1),
                             .wrong(index: 1, arrayCount: 1))
    }

    func testComputeIndex_SingleElementArray_NegativeIndex() throws {
        let result = try PathExplorers.Json.computeIndex(from: -1, arrayCount: 1)

        XCTAssertEqual(result, 0)
    }

    func testComputeIndex_OutOfBounds_PositiveIndexThrows() throws {
        XCTAssertErrorsEqual(try PathExplorers.Json.computeIndex(from: 5, arrayCount: 4),
                             .wrong(index: 5, arrayCount: 4))
    }

}
