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
        let path = stubPath.appending(.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 10, path: path), 2...7)
    }

    func testGetArraySlice_FirstIndex() throws {
        let bounds = Bounds(lower: .first, upper: 5)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 10, path: path), 0...5)
    }

    func testGetArraySlice_LastIndex() throws {
        let bounds = Bounds(lower: 2, upper: .last)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 5, path: path), 2...5)
    }

    func testGetArraySlice_LowerNegative() throws {
        let bounds = Bounds(lower: -2, upper: .last)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 5, path: path), 3...5)
    }

    func testGetArraySlice_UpperNegative() throws {
        let bounds = Bounds(lower: 4, upper: -2)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 10, path: path), 4...8)
    }

    func testGetArraySlice_LowerNegativeAndUpperEquals0Throws() throws {
        let bounds = Bounds(lower: -2, upper: 0)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 10, path: path), .wrongBounds(bounds, in: path, lastValidIndex: 10))
    }

    func testGetArraySlice_LowerGreaterThanLastIndexThrows() throws {
        let bounds = Bounds(lower: 10, upper: 1)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 5, path: path), .wrongBounds(bounds, in: path, lastValidIndex: 5))
    }

    func testRange_LowerNegativeGreaterThanUpperThrows() throws {
        let bounds = Bounds(lower: -2, upper: 1)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 10, path: path), .wrongBounds(bounds, in: path, lastValidIndex: 10))
    }

    func testGetArraySlice_UpperLesserThanLowerThrows() throws {
        let bounds = Bounds(lower: 2, upper: 1)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 5, path: path), .wrongBounds(bounds, in: path, lastValidIndex: 5))
    }

    func testRange_UpperNegativeLesserThanLowerThrows() throws {
        let bounds = Bounds(lower: 5, upper: -7)
        let path = stubPath.appending(.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 10, path: path), .wrongBounds(bounds, in: path, lastValidIndex: 10))
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
