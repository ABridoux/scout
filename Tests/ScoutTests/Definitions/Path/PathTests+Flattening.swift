//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class PathFlatteningTests: XCTestCase {

    func testFlattenReplaceSlice1() throws {
        try testFlatten(
            pathString: "movies[1:5].title[2]",
            expected: "movies[3].title"
        )
    }

    func testFlattenReplaceSlice2() throws {
        try testFlatten(
            pathString: "movies[1:2].chapters[2][1]",
            expected: "movies[2].chapters[2]"
        )
    }

    func testFlattenReplaceSlice3() throws {
        try testFlatten(
            pathString: "[1:2][1][2][0]",
            expected: "[1][1][2]"
        )
    }

    func testFlattenReplaceSliceNegativeIndex() throws {
        try testFlatten(
            pathString: "[1:4][1][2][-1]",
            expected: "[3][1][2]"
        )
    }

    func testFlattenReplaceFilter() throws {
        try testFlatten(
            pathString: "people.#Robert|Tom#.#age|hobbies#.Tom.hobbies[1]",
            expected: "people.Tom.hobbies[1]"
        )
    }

    func testFlattenReplaceFilter2() throws {
        try testFlatten(
            pathString: "people.#Tom|Robert#.Robert.hobbies[0]",
            expected: "people.Robert.hobbies[0]"
        )
    }

    func testFlattenReplaceFilterTwice() throws {
        try testFlatten(
            pathString: "movies[1].#title|name#.hobbies.name[0]",
            expected: "movies[1].name.hobbies[0]"
        )
    }

    func testFlattenReplaceSliceAndFilter() throws {
        try testFlatten(
            pathString: "movies[1:5].#title|name#.title[2]",
            expected: "movies[3].title"
        )
    }

    func testFlattenReplaceSliceKeySlice() throws {
        try testFlatten(
            pathString: "movies[1:5].chapters[3:10][2][3]",
            expected: "movies[4].chapters[5]"
        )
    }

    func testFlatten1() throws {
        try testFlatten(
            pathString: "[1:3][1][2:3][:1][1][2][1]",
            expected: "[2][1][3][2]"
        )
    }

    func testFlatten1NegativeIndex() throws {
        try testFlatten(
            pathString: "[1:3][1][2:3][:1][-1][2][1]",
            expected: "[2][1][2][2]"
        )
    }

    func testFlatten2() throws {
        try testFlatten(
            pathString: "[1:3][2:3][1][2][3][1]",
            expected: "[2][3][2][3]"
        )
    }

    // MARK: Sorted key and indexes

    func testSortedKeysAndIndexes1() throws {
        let path1 = try Path(string: "movies[2].chapters[4]")
        let path2 = try Path(string: "movies[3].chapters[3]")
        let path3 = try Path(string: "movies[3].chapters[4]")

        XCTAssertEqual([path2, path3, path1].sortedByKeysAndIndexes(), [path1, path2, path3])
    }

    func testSortedKeysAndIndexes2() throws {
        let path1 = try Path(string: "actors.prices")
        let path2 = try Path(string: "movies[3].chapters[3]")
        let path3 = try Path(string: "movies[4].chapters[2]")

        XCTAssertEqual([path2, path3, path1].sortedByKeysAndIndexes(), [path1, path2, path3])
    }
}

extension PathFlatteningTests {

    func testFlatten(pathString: String, expected: String, file: StaticString = #file, line: UInt = #line) throws {
        let path = try Path(string: pathString)

        try path.forEach {
            if case let .slice(bounds) = $0 {
                _ = try bounds.range(arrayCount: .max)
            }
        }

        XCTAssertEqual(path.flattened().description, expected, file: file, line: line)
    }
}
