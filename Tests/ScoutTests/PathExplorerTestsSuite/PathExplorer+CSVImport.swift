//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerCSVImportTests: XCTestCase {

    typealias Explorer = EquatablePathExplorer & SerializablePathExplorer

    func testExplorerValue() throws {
        try test(PathExplorers.Json.self)
    }

    func testExplorerXML() throws {
//        try test(ExplorerXML.self)
    }

    func test<P: Explorer>(_ type: P.Type) throws {
        try testImportCSV_ArrayOfDictionaries(P.self)
        try testImportCSV_ArrayOfDictionaries_NestedArray(P.self)
        try testImportCSV_ArrayOfDictionaries_NestedDict(P.self)
        try testImportCSV_ArrayOfArrays(P.self)
        try testImportCSV_ArrayOfSingles(P.self)
    }

    func testStub() throws {
        // use this function to launch a test with a specific PathExplorer
    }

    // MARK: - Suite

    func testImportCSV_ArrayOfDictionaries<P: Explorer>(_ type: P.Type) throws {
        try test(
            P.self,
            csv:
            """
            Riri;Fifi;Loulou
            1;2;3
            4;5;6
            7;8;9
            """,
            headers: true,
            expected:
                [["Riri": 1, "Fifi": 2, "Loulou": 3],
                ["Riri": 4, "Fifi": 5, "Loulou": 6],
                ["Riri": 7, "Fifi": 8, "Loulou": 9]]
        )
    }

    func testImportCSV_ArrayOfDictionaries_NestedArray<P: Explorer>(_ type: P.Type) throws {
        try test(
            P.self,
            csv:
            """
            name;hobbies[0];hobbies[1];score
            Tom;cooking;video games;20.5
            Robert;surfing;cluedo;30.2
            """,
            headers: true,
            expected:
                [["name": "Tom", "hobbies": ["cooking", "video games"], "score": 20.5],
                 ["name": "Robert", "hobbies": ["surfing", "cluedo"], "score": 30.2]]
        )
    }

    func testImportCSV_ArrayOfDictionaries_NestedDict<P: Explorer>(_ type: P.Type) throws {
        try test(
            P.self,
            csv:
            """
            name.first;name.last;score
            Riri;Duck;20.5
            Fifi;Duck;30.2
            Loulou;Duck;10

            """,
            headers: true,
            expected:
                [["name": ["first": "Riri", "last": "Duck"], "score": 20.5],
                 ["name": ["first": "Fifi", "last": "Duck"], "score": 30.2],
                 ["name": ["first": "Loulou", "last": "Duck"], "score": 10]]
        )
    }

    func testImportCSV_ArrayOfArrays<P: Explorer>(_ type: P.Type) throws {
        try test(
            P.self,
            csv:
            """
            Riri;2;3
            Fifi;5;6
            Loulou;8;9
            """,
            headers: false,
            expected: [["Riri", 2, 3], ["Fifi", 5, 6], ["Loulou", 8, 9]]
        )
    }

    func testImportCSV_ArrayOfSingles<P: Explorer>(_ type: P.Type) throws {
        try test(
            P.self,
            csv:
            """
            1;2;3;4;5;6
            """,
            headers: false,
            expected: [1, 2, 3, 4, 5, 6]
        )
    }
}

// MARK: - Helpers

extension PathExplorerCSVImportTests {

    func test<P: EquatablePathExplorer & SerializablePathExplorer>(
        _ type: P.Type,
        csv: String,
        headers: Bool,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line) throws {

        let explorer = try P.fromCSV(string: csv, separator: ";", hasHeaders: headers)
        let expectedExplorer = P(value: expected)

        XCTAssertExplorersEqual(explorer, expectedExplorer,file: file, line: line)
    }
}
