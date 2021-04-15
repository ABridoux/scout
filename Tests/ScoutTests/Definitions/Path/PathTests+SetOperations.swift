//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout
import XCTest

final class PathSetOperationsTests: XCTestCase {

    func testCommonPrefix_Middle() {
        let path = Path(elements: "toto", 1, "Endo", .count)
        let otherPath = Path(elements: "toto", 1, "Endo")

        let intersection = path.commonPrefix(with: otherPath)

        XCTAssertEqual(Path(path[0...2]), Path(intersection))
    }

    func testCommonPrefix_Empty() {
        let path = Path(elements: "toto", 1, "Endo", .count)
        let otherPath = Path(elements: "Riri", "Fifi", "Loulou")

        let intersection = path.commonPrefix(with: otherPath)

        XCTAssertEqual(Path.empty, Path(intersection))
    }

    func testCommonPrefix_All() {
        let path = Path(elements: "toto", 1, "Endo", .count)
        let otherPath = Path(elements: "toto", 1, "Endo", .count)

        let intersection = path.commonPrefix(with: otherPath)

        XCTAssertEqual(path, Path(intersection))
    }
}
