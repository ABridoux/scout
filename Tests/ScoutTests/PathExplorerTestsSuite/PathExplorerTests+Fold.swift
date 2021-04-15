//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerFoldTests: XCTestCase {

    func testExplorerValue() throws {
        try test(CodableFormatPathExplorer<CodableFormats.JsonDefault>.self)
    }

    func testExplorerXML() throws {
        try test(ExplorerXML.self)
    }

    func test<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFold_1Level_SingleValues(P.self)
        try testFold_1Level_DictionaryOfDictionaries(P.self)
        try testFold_1Level_DictionaryOfArrays(P.self)
        try testFold_1Level_ArrayOfDictionaries(P.self)
        try testFold_1Level_ArrayOfArrays(P.self)
        try testFold_0Level_DictionaryOfDictionaries(P.self)
        try testFold_0Level_ArrayOfDictionaries(P.self)
    }

    func testStub() throws {}

    func testFold_1Level_SingleValues<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: ["Toto": 10, "Endo": true, "Riri": 20.5],
            level: 1,
            expected: ["Toto": 10, "Endo": true, "Riri": 20.5]
        )
    }

    func testFold_1Level_DictionaryOfDictionaries<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: ["dog": ["name": "Endo", "score": 10], "cat": ["name": "Socrate", "score": 30]],
            level: 1,
            expected: ["dog": ["Folded": "~~SCOUT_FOLDED~~"], "cat": ["Folded": "~~SCOUT_FOLDED~~"]]
        )
    }

    func testFold_1Level_DictionaryOfArrays<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: ["dogs": ["Endo", "Jocky"], "cats": ["Mocka", "Whisky"]],
            level: 1,
            expected: ["dogs": ["~~SCOUT_FOLDED~~"], "cats": ["~~SCOUT_FOLDED~~"]]
        )
    }

    func testFold_1Level_ArrayOfDictionaries<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: [["name": "Endo", "score": 10], ["name": "Socrate", "score": 30]],
            level: 1,
            expected: [["Folded": "~~SCOUT_FOLDED~~"], ["Folded": "~~SCOUT_FOLDED~~"]]
        )
    }

    func testFold_1Level_ArrayOfArrays<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: [["Endo", "Jocky"], ["Mocka", "Whisky"]],
            level: 1,
            expected: [["~~SCOUT_FOLDED~~"], ["~~SCOUT_FOLDED~~"]]
        )
    }

    func testFold_0Level_DictionaryOfDictionaries<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: ["dog": ["name": "Endo", "score": 10], "cat": ["name": "Socrate", "score": 30]],
            level: 0,
            expected: ["Folded": "~~SCOUT_FOLDED~~"]
        )
    }

    func testFold_0Level_ArrayOfDictionaries<P: SerializablePathExplorer & EquatablePathExplorer>(_ type: P.Type) throws {
        try testFolded(
            P.self,
            value: [["name": "Endo", "score": 10], ["name": "Socrate", "score": 30]],
            level: 0,
            expected: ["~~SCOUT_FOLDED~~"]
        )
    }
}

// MARK: - Helpers

extension PathExplorerFoldTests {

    func testFolded<P: SerializablePathExplorer & EquatablePathExplorer>(
        _ type: P.Type,
        value: ExplorerValue,
        level: Int,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line) throws {
        let explorer = P(value: value)
        let expected = P(value: expected)

        let folded = explorer.folded(upTo: level)

        XCTAssertExplorersEqual(folded, expected, file: file, line: line)
    }

}
