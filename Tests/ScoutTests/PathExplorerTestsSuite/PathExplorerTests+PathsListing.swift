//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerPathsListingTests: XCTestCase {

    // MARK: - Functions

    func testExplorerValue() throws {
        try test(ExplorerValue.self)
    }

    func testExplorerXML() throws {
        try test(ExplorerXML.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // target only
        try testListPaths_SingleValues(P.self)
        try testListPath_GroupValues(P.self)
        try testListPaths_SingleAndGroup(P.self)

        // regex
        try testListPaths_SingleAndGroup_Regex(P.self)
        try testListPaths_Group_Regex(P.self)
        try testListPaths_Single_Regex(P.self)

        // predicate
        try testListPaths_Predicate(P.self)
        try testListPaths_2Predicates(P.self)
        try testListPaths_RegexAndPredicate(P.self)

        // initial path
        try testListPath_InitialPath(P.self)
        try testListPath_InitialPath_Filter(P.self)
    }

    func testStub() throws {
        // use this function to launch a test with a specific PathExplorer
        try testListPaths_SingleAndGroup_Regex(ExplorerXML.self)
    }

    // MARK: - Target only

    func testListPaths_SingleValues<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30],
            filter: .targetOnly(.single),
            expectedPaths: [Path("duration"),
                            Path("players", 0, "name"), Path("players", 0, "score"),
                            Path("players", 1, "name"), Path("players", 1, "score")]
        )
    }

    func testListPath_GroupValues<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30],
            filter: .targetOnly(.group),
            expectedPaths: [Path("players"), Path("players", 0), Path("players", 1)]
        )
    }

    func testListPaths_SingleAndGroup<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10], ["name": "Mister MV", "score": 20]], "duration": 30],
            filter: .targetOnly(.singleAndGroup),
            expectedPaths: [Path("duration"),
                            Path("players"),
                            Path("players", 0), Path("players", 0, "name"), Path("players", 0, "score"),
                            Path("players", 1), Path("players", 1, "name"), Path("players", 1, "score")]
        )
    }

    // MARK: - Regex

    func testListPaths_SingleAndGroup_Regex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .key(regex: NSRegularExpression(pattern: ".*name.*")),
            expectedPaths: [Path("names"), Path("names", 0), Path("names", 1), Path("players", 0, "name"), Path("players", 1, "name")]
        )
    }

    func testListPaths_Group_Regex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .key(regex: NSRegularExpression(pattern: ".*name.*"), target: .group),
            expectedPaths: [Path("names")]
        )
    }

    func testListPaths_Single_Regex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .key(regex: NSRegularExpression(pattern: ".*name.*"), target: .single),
            expectedPaths: [Path("names", 0), Path("names", 1), Path("players", 0, "name"), Path("players", 1, "name")]
        )
    }

    // MARK: - Predicate

    func testListPaths_Predicate<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .value("value < 30"),
            expectedPaths: [Path("players", 0, "score"), Path("players", 1, "score")])
    }

    func testListPaths_2Predicates<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .value("value < 30", "value isIn 'Zerator, Mister MV'"),
            expectedPaths: [Path("players", 0, "name"), Path("players", 0, "score"), Path("players", 1, "name"), Path("players", 1, "score")])
    }

    func testListPaths_RegexAndPredicate<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30,
                       "names": ["ZEvent", "EventZ"]],
            filter: .keyAndValue(pattern: "score", valuePredicatesFormat: "value > 0"),
            expectedPaths: [Path("players", 0, "score"), Path("players", 1, "score")])
    }

    // MARK: - Initial path

    func testListPath_InitialPath<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["players": [["name": "Zerator", "score": 10],
                                   ["name": "Mister MV", "score": 20]],
                       "duration": 30],
            leadingPath: ["players"],
            filter: .noFilter,
            expectedPaths: [Path("players", 0), Path("players", 0, "name"), Path("players", 0, "score"),
                            Path("players", 1), Path("players", 1, "name"), Path("players", 1, "score")]
        )
    }

    func testListPath_InitialPath_Filter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testListPaths(
            P.self,
            explorer: ["Riri": ["score": 30, "rank": 1],
                       "Fifi": ["score": 30, "rank": 1],
                       "Loulou": ["score": 30, "rank": 1]],
            leadingPath: [.filter("Riri|Fifi"), "score"],
            filter: .noFilter,
            expectedPaths: [Path("Fifi", "score"), Path("Riri", "score")]
        )
    }
}

// MARK: - Helpers

extension PathExplorerPathsListingTests {

    func testListPaths<P: EquatablePathExplorer>(
        _ type: P.Type,
        explorer: ExplorerValue,
        leadingPath: [PathElement]? = nil,
        filter: PathsFilter,
        expectedPaths: [Path],
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        let explorer = P(value: explorer)

        var initialPath: Path?
        if let path = leadingPath {
            initialPath = Path(path)
        }
        let paths = try explorer.listPaths(startingAt: initialPath, filter: filter).sortedByKeysAndIndexes()

        XCTAssertEqual(paths, expectedPaths, file: file, line: line)
    }
}
