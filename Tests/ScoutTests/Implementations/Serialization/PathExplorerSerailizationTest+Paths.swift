//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathExplorerSerializationPathsTest: XCTestCase {

    // MARK: - Properties

    var players: [String: Any] {
        var dict = [String: Any]()
        let firstPlayer: [String: Any] = ["name": "Zerator", "score": 10]
        let secondPlayer: [String: Any] = ["name": "Mister MV", "score": 20]
        dict["duration"] = 30
        dict["players"] = [firstPlayer, secondPlayer]

        return dict
    }

    var events: [String: Any] {
        var dict = players
        dict["name"] = ["Zevent", "EventZ"]

        return dict
    }

    // MARK: - Functions

    func testGetKeysPathsSingleValues() throws {
        let explorer = Json(value: players)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.single))

        let expectedPaths: Set<Path> = [Path("duration"), Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsGroupValues() throws {
        let explorer = Json(value: players)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.group))

        let expectedPaths: Set<Path> = [Path("players"), Path("players", 0), Path("players", 1)]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsGroupAndSingleValues() throws {
        let explorer = Json(value: players)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.singleAndGroup))

        let expectedPaths: Set<Path> = [Path("players"),
                                        Path("duration"),
                                        Path("players", 0),
                                        Path("players", 0, "name"),
                                        Path("players", 0, "score"),
                                        Path("players", 1),
                                        Path("players", 1, "name"),
                                        Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsArrayOrder() throws {
        var dict = [String: Any]()
        let firstPlayer: [String: Any] = ["name": "Zerator"]
        let secondPlayer: [String: Any] = ["name": "Mister MV"]
        let thirdPlayer: [String: Any] = ["name": "Maghla"]
        dict["players"] = [firstPlayer, secondPlayer, thirdPlayer]
        let explorer = Json(value: dict)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.single))

        let expectedPaths = [Path("players", 0, "name"), Path("players", 1, "name"), Path("players", 2, "name")]
        XCTAssertEqual(paths, expectedPaths)
    }

    func testGetKeysPathsWithKeyPatternSingleAndGroup() throws {
        let explorer = Json(value: events)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: "name")

        explorer.collectKeysPaths(in: &paths, filter: .key(regex: regex))

        let expectedPaths: Set<Path> = [Path("name"), Path("name", 0), Path("name", 1), Path("players", 0, "name"), Path("players", 1, "name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsWithKeyPatternGroup() throws {
        let explorer = Json(value: events)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: "name")

        explorer.collectKeysPaths(in: &paths, filter: .key(regex: regex, target: .group))

        let expectedPaths: Set<Path> = [Path("name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }
}
