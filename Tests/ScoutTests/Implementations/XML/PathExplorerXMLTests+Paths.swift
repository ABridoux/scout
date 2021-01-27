//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML
import XCTest
@testable import Scout

final class PathExplorerXMLPathsTests: XCTestCase {

    // MARK: - Properties

    var players: AEXMLElement {
        let players = AEXMLElement(name: "players")

        let firstPlayer = AEXMLElement(name: "player")
        firstPlayer.addChild(name: "name", value: "Zerator")
        firstPlayer.addChild(name: "score", value: "10")
        let secondPlayer = AEXMLElement(name: "player")
        secondPlayer.addChild(name: "name", value: "Mister MV")
        secondPlayer.addChild(name: "score", value: "20")

        players.addChildren([firstPlayer, secondPlayer])
        let root = AEXMLElement(name: "root")
        root.addChild(players)

        root.addChild(name: "duration", value: "20")

        return root
    }

    var events: AEXMLElement {
        let players = AEXMLElement(name: "players")
        let firstPlayer = AEXMLElement(name: "player")
        firstPlayer.addChild(name: "name", value: "Zerator")
        firstPlayer.addChild(name: "score", value: "10")
        let secondPlayer = AEXMLElement(name: "player")
        secondPlayer.addChild(name: "name", value: "Mister MV")
        secondPlayer.addChild(name: "score", value: "20")

        let events = AEXMLElement(name: "name")
        events.addChild(name: "name", value: "Zevent")
        events.addChild(name: "name", value: "EventZ")

        players.addChildren([firstPlayer, secondPlayer])
        let root = AEXMLElement(name: "root")
        root.addChild(events)
        root.addChild(players)

        root.addChild(name: "duration", value: "20")

        return root
    }

    // MARK: - Functions

    func testGetKeysPathsSingleValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, valueType: .single)

        let expectedPaths: Set<Path> = [Path("duration"), Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsGroupValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, valueType: .group)

        let expectedPaths: Set<Path> = [Path("players"), Path("players", 0), Path("players", 1)]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsGroupAndSingleValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, valueType: .singleAndGroup)

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
        let root = AEXMLElement(name: "root")
        root.addChild(name: "duration", value: "20")
        let players = AEXMLElement(name: "players")
        let firstPlayer = AEXMLElement(name: "player")
        firstPlayer.addChild(name: "name", value: "Zerator")
        firstPlayer.addChild(name: "score", value: "10")
        let secondPlayer = AEXMLElement(name: "player")
        secondPlayer.addChild(name: "name", value: "Mister MV")
        secondPlayer.addChild(name: "score", value: "20")
        players.addChildren([firstPlayer, secondPlayer])
        root.addChild(players)
        let explorer = Xml(element: root, path: .empty)
        var paths = [Path]()

        explorer.collectKeysPaths(in: &paths, valueType: .single)

        let expectedPaths = [Path("duration"), Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")]
        XCTAssertEqual(paths, expectedPaths)
    }

    func testGetKeysPathsWithKeyPatternSingleAndGroup() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: "name")

        explorer.collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: .singleAndGroup)

        let expectedPaths: Set<Path> = [Path("name"), Path("name", 0), Path("name", 1), Path("players", 0, "name"), Path("players", 1, "name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testGetKeysPathsWithKeyPatternGroup() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: "name")

        explorer.collectKeysPaths(in: &paths, whereKeyMatches: regex, valueType: .group)

        let expectedPaths: Set<Path> = [Path("name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }
}
