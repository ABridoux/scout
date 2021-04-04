//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerSetTests: XCTestCase {

    // MARK: - Functions

    func test() throws {
        try test(ExplorerValue.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testSetKey(P.self)
        try testSetKey_Nested(P.self)
        try testSetKeyName_ThrowsOnNonDictionary(P.self)
        try testSetKey_ThrowsOnNonDictionary_Nested(P.self)

        // index
        try testSetIndex(P.self)
        try testSetIndex_Negative(P.self)
        try testSetIndex_Nested(P.self)
        try testSetIndex_ThrowsOnNonArray(P.self)
        try testSetIndex_ThrowsOnNonArray_Nested(P.self)

        // key name
        try testSetKeyName_Key(P.self)
        try testSetKeyName_NestedKey(P.self)
        try testSetKeyName_NestedIndex(P.self)
        try testSetKeyName_ThrowsOnNonDictionary(P.self)
        try testSetKeyName_IndexThrowsOnNonArray(P.self)
    }

    func testStub() throws {
        // use this function to launch a test with a specific PathExplorer
    }

    // MARK: - Key

    func testSetKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: ["toto": 2, "Endo": false],
            path: "toto",
            value: 3,
            expected: ["toto": 3, "Endo": false]
        )
    }

    func testSetKey_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: ["toto": ["Riri": 2], "Endo": false],
            path: "toto", "Riri",
            value: 3.5,
            expected: ["toto": ["Riri": 3.5], "Endo": false]
         )
    }

    func testSetKeyName_ThrowsOnNonDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto", 1])

        XCTAssertErrorsEqual(try explorer.set("toto", to: 1), .subscriptKeyNoDict)
    }

    func testSetKey_ThrowsOnNonDictionary_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto": [true]])

        XCTAssertErrorsEqual(try explorer.set("toto", "Endo", to: 1),
                             ExplorerError.subscriptKeyNoDict.with(path: "toto"))
    }

    // MARK: - Index

    func testSetIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: [1, false, "toto"],
            path: 1,
            value: 2.3,
            expected: [1, 2.3, "toto"]
        )
    }

    func testSetIndex_Negative<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: [1, false, "toto"],
            path: -2,
            value: 2.3,
            expected: [1, 2.3, "toto"]
        )
    }

    func testSetIndex_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: [[1, 2, 3], [4, 5, 6]],
            path: 1, 0,
            value: "here",
            expected: [[1, 2, 3], ["here", 5, 6]]
        )
    }

    func testSetIndex_ThrowsOnNonArray<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto": 2, "Endo": false])

        XCTAssertErrorsEqual(try explorer.set(1, to: 2), .subscriptIndexNoArray)
    }

    func testSetIndex_ThrowsOnNonArray_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [["Endo": 2]])

        XCTAssertErrorsEqual(try explorer.set(0, 1, to: 2),
                             ExplorerError.subscriptIndexNoArray.with(path: 0))
    }

    // MARK: - Key name

    func testSetKeyName_Key<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSetKeyName(
            P.self,
            initial: ["toto": 2, "Endo": false],
            path: "toto",
            value: "tata",
            expected: ["tata": 2, "Endo": false]
        )
    }

    func testSetKeyName_NestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSetKeyName(
            P.self,
            initial: ["toto": ["Endo": 2]],
            path: "toto", "Endo",
            value: "Socrate",
            expected: ["toto": ["Socrate": 2]]
        )
    }

    func testSetKeyName_NestedIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSetKeyName(
            P.self,
            initial: [["toto": 2], ["toto": 1]],
            path: 0, "toto",
            value: "Endo",
            expected: [["Endo": 2], ["toto": 1]]
        )
    }

    func testSetKeyName_KeyThrowsOnNonDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [1, 2, 3])

        XCTAssertErrorsEqual(try explorer.set(1, keyNameTo: "toto"), .subscriptKeyNoDict)
    }

    func testSetKeyName_IndexThrowsOnNonArray<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["Toto": 10, "Endo": true])

        XCTAssertErrorsEqual(try explorer.set(1, keyNameTo: "toto"), .wrongUsage(of: 1))
    }
}

// MARK: - Helpers

extension PathExplorerSetTests {

    func testSet<P: EquatablePathExplorer>(
        _ type: P.Type,
        initial: ExplorerValue,
        path: PathElement...,
        value: ExplorerValue,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        var explorer = P(value: initial)
        let expectedExplorer = P(value: expected)

        try explorer.set(path, to: value)

        XCTAssertExplorersEqual(explorer, expectedExplorer, file: file, line: line)
    }

    func testSetKeyName<P: EquatablePathExplorer>(
        _ type: P.Type,
        initial: ExplorerValue,
        path: PathElement...,
        value: String,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        var explorer = P(value: initial)
        let expectedExplorer = P(value: expected)

        try explorer.set(path, keyNameTo: value)

        XCTAssertExplorersEqual(explorer, expectedExplorer, file: file, line: line)
    }
}
