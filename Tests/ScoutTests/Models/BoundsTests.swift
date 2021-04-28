//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class BoundsTests: XCTestCase {

    let stubPath = Path("flower", "power")

    func testGetArraySlice() throws {
        let bounds = Bounds(lower: 2, upper: 7)

        XCTAssertEqual(try bounds.range(arrayCount: 11), 2...7)
    }

    func testGetArraySlice_FirstIndex() throws {
        let bounds = Bounds(lower: .first, upper: 5)

        XCTAssertEqual(try bounds.range(arrayCount: 11), 0...5)
    }

    func testGetArraySlice_LastIndex() throws {
        let bounds = Bounds(lower: 2, upper: .last)

        XCTAssertEqual(try bounds.range(arrayCount: 6), 2...5)
    }

    func testGetArraySlice_LowerNegative() throws {
        let bounds = Bounds(lower: -2, upper: .last)

        XCTAssertEqual(try bounds.range(arrayCount: 6), 4...5)
    }

    func testGetArraySlice_UpperNegative() throws {
        let bounds = Bounds(lower: 4, upper: -2)

        XCTAssertEqual(try bounds.range(arrayCount: 10), 4...8)
    }

    func testGetArraySlice_LowerNegativeAndUpperEquals0Throws() throws {
        let bounds = Bounds(lower: -2, upper: 0)

        XCTAssertErrorsEqual(try bounds.range(arrayCount: 11), .wrong(bounds: bounds, arrayCount: 11))
    }

    func testGetArraySlice_LowerGreaterThanLastIndexThrows() throws {
        let bounds = Bounds(lower: 10, upper: 1)

        XCTAssertErrorsEqual(try bounds.range(arrayCount: 6), .wrong(bounds: bounds, arrayCount: 6))
    }

    func testRange_LowerNegativeGreaterThanUpperThrows() throws {
        let bounds = Bounds(lower: -2, upper: 1)

        XCTAssertErrorsEqual(try bounds.range(arrayCount: 11), .wrong(bounds: bounds, arrayCount: 11))
    }

    func testGetArraySlice_UpperLesserThanLowerThrows() throws {
        let bounds = Bounds(lower: 2, upper: 1)

        XCTAssertErrorsEqual(try bounds.range(arrayCount: 6), .wrong(bounds: bounds, arrayCount: 6))
    }

    func testRange_UpperNegativeLesserThanLowerThrows() throws {
        let bounds = Bounds(lower: 5, upper: -7)

        XCTAssertErrorsEqual(try bounds.range(arrayCount: 11), .wrong(bounds: bounds, arrayCount: 11))
    }

    func testEqualBound() {
        let bound5 = Bounds.Bound(5)
        let bound5Bis = Bounds.Bound(5)

        XCTAssertEqual(bound5, bound5Bis)
    }

    func testNotEqualsBound() {
        let bound5 = Bounds.Bound(5)
        let bound10 = Bounds.Bound(10)

        XCTAssertNotEqual(bound5, bound10)
    }

    func testNotEqualsBoundWithIdentifier() {
        let bound5 = Bounds.Bound(5)
        let bound5WithIdentifier = Bounds.Bound.last

        XCTAssertNotEqual(bound5, bound5WithIdentifier)
    }
}
