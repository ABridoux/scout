//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerSetTests: XCTestCase {

    // MARK: - Functions

    func test() throws {
        try test(ValueType.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testSetKey(P.self)
        try testSetNestedKey(P.self)
        try testSetKeyOnNonDictionaryThrows(P.self)
        try testSetKeyOnNonDictionaryThrows_Nested(P.self)

        // index
        try testSetIndex(P.self)
        try testSetNegativeIndex(P.self)
        try testSetIndexOnNonArrayThrows(P.self)
        try testSetIndexOnNonArrayThrows_Nested(P.self)

        // key name
        try testSetKeyName(P.self)
    }

    func testStub() throws {
        // use this function to launch a specific test with a specific PathExplorer
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

    func testSetNestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: ["toto": ["Riri": 2], "Endo": false],
            path: "toto", "Riri",
            value: 3.5,
            expected: ["toto": ["Riri": 3.5], "Endo": false]
         )
    }

    func testSetKeyOnNonDictionaryThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto", 1])

        XCTAssertErrorsEqual(try explorer.set("toto", to: 1), .subscriptKeyNoDict)
    }

    func testSetKeyOnNonDictionaryThrows_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto": [true]])

        XCTAssertErrorsEqual(try explorer.set("toto", "Endo", to: 1),
                             ValueTypeError.subscriptKeyNoDict.with(path: "toto"))
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

    func testSetNegativeIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testSet(
            P.self,
            initial: [1, false, "toto"],
            path: -2,
            value: 2.3,
            expected: [1, 2.3, "toto"]
        )
    }

    func testSetIndexOnNonArrayThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto": 2, "Endo": false])

        XCTAssertErrorsEqual(try explorer.set(1, to: 2), .subscriptIndexNoArray)
    }

    func testSetIndexOnNonArrayThrows_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [["Endo": 2]])

        XCTAssertErrorsEqual(try explorer.set(0, 1, to: 2),
                             ValueTypeError.subscriptIndexNoArray.with(path: 0))
    }

    // MARK: - Key name

    func testSetKeyName<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["toto": 2, "Endo": false])
        let expected = P(value: ["tata": 2, "Endo": false])

        try explorer.set("toto", keyNameTo: "tata")

        XCTAssertExplorersEqual(explorer, expected)
    }
}

// MARK: - Helpers

extension PathExplorerSetTests {

    func testSet<P: EquatablePathExplorer>(
        _ type: P.Type,
        initial: ValueType,
        path: PathElement...,
        value: ValueType,
        expected: ValueType,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        var explorer = P(value: initial)
        let expectedExplorer = P(value: expected)

        try explorer.set(path, to: value)

        XCTAssertExplorersEqual(explorer, expectedExplorer, file: file, line: line)
    }
}
