//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class TreeTests: XCTestCase {

    func testInsert1() {
        var tree = Tree<String>()

        XCTAssertEqual(tree.insert(value: "c"), 0)
        XCTAssertEqual(tree.insert(value: "a"), 0)
        XCTAssertEqual(tree.insert(value: "b"), 1)
        XCTAssertEqual(tree.insert(value: "e"), 3)
    }

    func testInsert2() {
        var tree = Tree<String>()

        XCTAssertEqual(tree.insert(value: "d"), 0)
        XCTAssertEqual(tree.insert(value: "a"), 0)
        XCTAssertEqual(tree.insert(value: "b"), 1)
        XCTAssertEqual(tree.insert(value: "c"), 2)
    }
}
