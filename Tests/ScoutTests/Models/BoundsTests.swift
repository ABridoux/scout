//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class BoundsTests: XCTestCase {

    func testGetArraySlice_LastIndex() throws {
        let bounds = Bounds(lower: 2, upper: -1)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 5, path: path), 2...5)
    }

    func testGetArraySlice_LowerLesserThan0() throws {
        let bounds = Bounds(lower: -2, upper: -1)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertEqual(try bounds.range(lastValidIndex: 5, path: path), 4...5)
    }

    func testRange_ThrowsIfLowerLesserThan0() throws {
        let bounds = Bounds(lower: -2, upper: 1)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 10, path: path), .wrongBounds(bounds, in: path))
    }

    func testGetArraySlice_ThrowsIfLowerGreaterThanLastIndex() throws {
        let bounds = Bounds(lower: 10, upper: 1)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 5, path: path), .wrongBounds(bounds, in: path))
    }

    func testGetArraySlice_ThrowsIfUpperLesserThanLower() throws {
        let bounds = Bounds(lower: 2, upper: 1)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 5, path: path), .wrongBounds(bounds, in: path))
    }

    func testGetArraySlice_ThrowsIfUpperEqualsLower() throws {
        let bounds = Bounds(lower: 2, upper: 2)
        let path = Path("flower", "power", PathElement.slice(bounds))

        XCTAssertErrorsEqual(try bounds.range(lastValidIndex: 5, path: path), .wrongBounds(bounds, in: path))
    }
}
