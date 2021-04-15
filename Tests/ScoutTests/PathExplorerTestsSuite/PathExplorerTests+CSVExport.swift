//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerCSVExportTests: XCTestCase {

    func testExplorerValue() throws {
        try test(CodableFormatPathExplorer<CodableFormats.JsonDefault>.self)
    }

    func testExplorerXML() throws {
        try test(ExplorerXML.self)
    }

    func test<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV_SingleValues(P.self)
        try testExportCSV_ArrayOfDictionaries(P.self)
        try testExportCSV_ArrayOfDictionaries_NestedDict(P.self)
        try testExportCSV_ArrayOfDictionaries_NestedDifferentDicts(P.self)
        try testExportCSV_ArrayOfDictionaries_NestedArray(P.self)
        try testExportCSV_ArrayOfArrays(P.self)
        try testExportCSV_DictionaryOfArrays(P.self)
        try testExportCSV_SeparatorIsQuoted(P.self)
    }

    func testStub() throws {
        // use this function to launch a test with a specific PathExplorer
    }

    func testExportCSV_SingleValues<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: ["Riri", "Fifi", "Loulou"],
            expected: "Riri;Fifi;Loulou;"
        )
    }

    func testExportCSV_ArrayOfDictionaries<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: [["name": "Riri", "age": 15], ["name": "Fifi", "age": 15], ["name": "Loulou", "age": 15]],
            expected:
            """
            age;name;
            15;Riri;
            15;Fifi;
            15;Loulou;
            """
        )
    }

    func testExportCSV_ArrayOfDictionaries_NestedDict<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: [["name": "Riri", "family": ["uncle": "Donald", "aunt": "Daisy"]],
                     ["name": "Fifi", "family": ["uncle": "Donald", "aunt": "Daisy"]],
                     ["name": "Loulou", "family": ["uncle": "Donald", "aunt": "Daisy"]]],
            expected:
            """
            family.aunt;family.uncle;name;
            Daisy;Donald;Riri;
            Daisy;Donald;Fifi;
            Daisy;Donald;Loulou;
            """
        )
    }

    func testExportCSV_ArrayOfDictionaries_NestedDifferentDicts<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: [["name": "Riri", "family": ["aunt": "Daisy"]],
                     ["name": "Fifi", "family": ["uncle": "Donald", "aunt": "Daisy"]],
                     ["name": "Loulou", "family": ["uncle": "Donald"]]],
            expected:
            """
            family.aunt;family.uncle;name;
            Daisy;NULL;Riri;
            Daisy;Donald;Fifi;
            NULL;Donald;Loulou;
            """
        )
    }

    func testExportCSV_ArrayOfDictionaries_NestedArray<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: [["name": "Riri", "brothers": ["Fifi", "Loulou"]],
                     ["name": "Fifi", "brothers": ["Riri", "Loulou"]],
                     ["name": "Loulou", "brothers": ["Riri", "Fifi"]]],
            expected:
            """
            brothers[0];brothers[1];name;
            Fifi;Loulou;Riri;
            Riri;Loulou;Fifi;
            Riri;Fifi;Loulou;
            """
        )
    }

    func testExportCSV_ArrayOfArrays<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            expected:
            """
            1;2;3;
            4;5;6;
            7;8;9;
            """
        )
    }

    func testExportCSV_DictionaryOfArrays<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: ["duckFamily": ["Donald", "Daisy"], "mouseFamily": ["Mickey", "Minnie"]],
            expected:
            """
            duckFamily;Donald;Daisy;
            mouseFamily;Mickey;Minnie;
            """
        )
    }

    func testExportCSV_SeparatorIsQuoted<P: SerializablePathExplorer>(_ type: P.Type) throws {
        try testExportCSV(
            P.self,
            value: ["phrase with; separator", "phrase without separator"],
            expected:
            """
            "phrase with; separator";phrase without separator;
            """
        )
    }
}

extension PathExplorerCSVExportTests {

    func testExportCSV<P: SerializablePathExplorer>(
        _ type: P.Type,
        value: ExplorerValue,
        separator: String = ";",
        expected: String,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        let explorer = P(value: value)

        try XCTAssertEqual(explorer.exportCSV(separator: separator), expected, file: file, line: line)
    }
}
