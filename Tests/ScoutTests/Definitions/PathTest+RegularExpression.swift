//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class PathExtensionsTests: XCTestCase {

    // MARK: Key regex

    func testLastKeyRegexSimple() throws {
        let path = Path("ducks", "age")
        let ageRegex = try NSRegularExpression(pattern: "age")
        let ducksRegex = try NSRegularExpression(pattern: "ducks")

        XCTAssertTrue(path.lastKeyComponent(matches: ageRegex))
        XCTAssertFalse(path.lastKeyComponent(matches: ducksRegex))
    }

    func testLastKeyRegexComplex() throws {
        let path = Path("ducks", "age", "mouses", 2)
        let correctRegex = try NSRegularExpression(pattern: ".*mo.*")
        let wrongRegex = try NSRegularExpression(pattern: ".*mo[0-9]{1}.*")

        XCTAssertTrue(path.lastKeyComponent(matches: correctRegex))
        XCTAssertFalse(path.lastKeyComponent(matches: wrongRegex))
    }

    // MARK: Smart description

    func testSmartDescriptionReplaceSlice() throws {
        try testPathSmartDescription("movies[1:5].title[2]", expected: "movies[3].title")
    }

    func testSmartDescriptionReplaceFilter() throws {
        try testPathSmartDescription("movies[1].#title|name#.hobbies.name[0]", expected: "movies[1].name.hobbies[0]")
    }

    func testSmartDescriptionReplaceSliceAndFilter() throws {
        try testPathSmartDescription("movies[1:5].#title|name#.title[2]", expected: "movies[3].title")
    }

    func testSmartDescriptionReplaceSliceKeySlice() throws {
        try testPathSmartDescription("movies[1:5].chapters[3:10][2][3]", expected: "movies[4].chapters[5]")
    }

    func testSmartDescription1() throws {
        try testPathSmartDescription("[1:3][1][2:3][:1][1][2][1]", expected: "[2][1][3][2]")
    }

    func testSmartDescription2() throws {
        try testPathSmartDescription("[1:3][2:3][1][2][3][1]", expected: "[2][3][2][3]")
    }

    func testPathSmartDescription(_ description: String, expected: String) throws {
        let path = try Path(string: description)
        try path.forEach {
            if case let .slice(bounds) = $0 {
                _ = try bounds.range(lastValidIndex: .max, path: .empty)
            }
        }

        XCTAssertEqual(path.flattened().description, expected)
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
