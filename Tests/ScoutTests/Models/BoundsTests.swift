//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

import XCTest
import Scout

final class BoundsTests: XCTestCase {

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
