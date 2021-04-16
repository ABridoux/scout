//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class PathExplorerAddTests: XCTestCase {

    func testExplorerValue() throws {
        try test(ExplorerValue.self)

        // specific tests for serializable values
        try testAddKey_ThrowsOnNonDictionary(ExplorerValue.self)
    }

    func testExplorerXML() throws {
        try test(ExplorerXML.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testAddKey(P.self)
        try testAddKey_NestedKey(P.self)
        try testAddKey_NestedIndex(P.self)
        try testAddKey_UnknownKeyIsCreated(P.self)
        try testAddKey_GroupValue(P.self)
        try testAddKey_ThrowsIfWrongElement(P.self)

        // index
        try testAddIndex(P.self)
        try testAddIndex_Negative(P.self)
        try testAddIndex_NestedIndex(P.self)
        try testAddIndex_NestedKey(P.self)
        try testAddIndex_GroupValue(P.self)

        // count
        try testAddCount(P.self)
        try testAddCount_Nested(P.self)
        try testAddCount_EmptyArray(P.self)
    }

    func testStub() throws {
        // use this function to launch a test with a specific PathExplorer
        try testAddCount_Nested(ExplorerXML.self)
    }

    // MARK: - Key

    func testAddKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: ["Endo": 2, "Toto": true],
            path: "Riri",
            value: 2.5,
            expected: ["Endo": 2, "Toto": true, "Riri": 2.5]
        )
    }

    func testAddKey_NestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: ["Endo": ["Toto": 2]],
            path: "Endo", "Riri",
            value: 2.5,
            expected: ["Endo": ["Toto": 2, "Riri": 2.5]]
        )
    }

    func testAddKey_NestedIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [["Toto": 2], ["Toto": 2]],
            path: 1, "Riri",
            value: 2.5,
            expected: [["Toto": 2], ["Toto": 2, "Riri": 2.5]]
        )
    }

    func testAddKey_UnknownKeyIsCreated<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: ["Endo": ["Toto": 2]],
            path: "Socrate", "Riri",
            value: 2.5,
            expected: ["Endo": ["Toto": 2], "Socrate": ["Riri": 2.5]]
        )
    }

    func testAddKey_GroupValue<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: ["Endo": 2, "Toto": true],
            path: "ducks",
            value: ["Riri", "Fifi", "Loulou"],
            expected: ["Endo": 2, "Toto": true, "ducks": ["Riri", "Fifi", "Loulou"]]
        )
    }

    func testAddKey_ThrowsOnNonDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [1, 2, 3])

        try XCTAssertErrorsEqual(explorer.add("to", at: "ta"), .subscriptKeyNoDict)
    }

    func testAddKey_ThrowsIfWrongElement<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [1, 2, 3])

        try XCTAssertErrorsEqual(explorer.add("to", at: .keysList), .wrongUsage(of: .keysList))
    }

    // MARK: - Index

    func testAddIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, true, "hello"],
            path: 2,
            value: 2.5,
            expected: [1, true, 2.5, "hello"]
        )
    }

    func testAddIndex_Negative<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, true, "hello"],
            path: -2,
            value: 2.5,
            expected: [1, 2.5, true, "hello"]
        )
    }

    func testAddIndex_NestedIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, [true, "hello"]],
            path: 1, 0,
            value: 2.5,
            expected: [1, [2.5, true, "hello"]]
        )
    }

    func testAddIndex_NestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: ["Endo": 1, "Toto": [1, 2, 3]],
            path: "Toto", 1,
            value: "here",
            expected: ["Endo": 1, "Toto": [1, "here", 2, 3]]
        )
    }

    func testAddIndex_GroupValue<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, true, "hello"],
            path: 2,
            value: [true, false],
            expected: [1, true, [true, false], "hello"]
        )
    }

    // MARK: - Count

    func testAddCount<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, true, "hello"],
            path: .count,
            value: 2.5,
            expected: [1, true, "hello", 2.5]
        )
    }

    func testAddCount_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [[1, 2], [1, 2], [1, 2]],
            path: .count, 0,
            value: "here",
            expected: [[1, 2], [1, 2], [1, 2], ["here"]]
        )
    }

    func testAddCount_EmptyArray<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testAdd(
            P.self,
            initial: [1, 2],
            path: 0, .count,
            value: "here",
            expected: [["here"], 2]
        )
    }
}

// MARK: - Helpers

extension PathExplorerAddTests {

    func testAdd<P: EquatablePathExplorer>(
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

        try explorer.add(value, at: Path(path))

        XCTAssertExplorersEqual(explorer, expectedExplorer, file: file, line: line)
    }
}
