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

        let events = AEXMLElement(name: "events_name")
        events.addChild(name: "name", value: "Zevent")
        events.addChild(name: "name", value: "EventZ")

        players.addChildren([firstPlayer, secondPlayer])
        let root = AEXMLElement(name: "root")
        root.addChild(events)
        root.addChild(players)

        root.addChild(name: "duration", value: "40")

        return root
    }

    // MARK: - Functions

    func testListPathsSingleValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        try explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.single))

        let expectedPaths: Set<Path> = [Path("duration"), Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListPathsGroupValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        try explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.group))

        let expectedPaths: Set<Path> = [Path("players"), Path("players", 0), Path("players", 1)]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListKeysPathsGroupAndSingleValues() throws {
        let explorer = Xml(element: players, path: .empty)
        var paths = [Path]()

        try explorer.collectKeysPaths(in: &paths, filter: .noFilter)

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

    func testListPathsArrayOrder() throws {
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

        try explorer.collectKeysPaths(in: &paths, filter: .targetOnly(.single))

        let expectedPaths = [Path("duration"), Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")]
        XCTAssertEqual(paths, expectedPaths)
    }

    func testListPathsKeyRegexSingleAndGroup() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: ".*name.*")

        try explorer.collectKeysPaths(in: &paths, filter: .key(regex: regex))

        let expectedPaths: Set<Path> = [Path("events_name"), Path("events_name", 0), Path("events_name", 1), Path("players", 0, "name"), Path("players", 1, "name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListPathsKeyRegexGroup() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let regex = try NSRegularExpression(pattern: ".*name.*")

        try explorer.collectKeysPaths(in: &paths, filter: .key(regex: regex, target: .group))

        let expectedPaths: Set<Path> = [Path("events_name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListPathsValuePRedicate() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let predicate = try PathsFilter.Predicate(format: "value < 30")

        try explorer.collectKeysPaths(in: &paths, filter: .value(predicate))

        let expectedPaths: Set<Path> = [Path("players", 0, "score"), Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListPaths2Filters() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let scorePredicate = try PathsFilter.Predicate(format: "value < 30")
        let namePredicate = try PathsFilter.Predicate(format: "value isIn 'Zerator, Mister MV'")

        try explorer.collectKeysPaths(in: &paths, filter: .value(scorePredicate, namePredicate))

        let expectedPaths: Set<Path> = [Path("players", 0, "score"), Path("players", 1, "score"), Path("players", 0, "name"), Path("players", 1, "name")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }

    func testListPathKeyRegexValuePredicate() throws {
        let explorer = Xml(element: events, path: .empty)
        var paths = [Path]()
        let nameRegex = try NSRegularExpression(pattern: "score")
        let scorePredicate = try PathsFilter.Predicate(format: "value > 0")

        try explorer.collectKeysPaths(in: &paths, filter: .keyAndValue(keyRegex: nameRegex, valuePredicates: scorePredicate))

        let expectedPaths: Set<Path> = [Path("players", 0, "score"), Path("players", 1, "score")]
        XCTAssertEqual(Set(paths), expectedPaths)
    }
}
