//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerDeleteTests: XCTestCase {

    func test() throws {
        try test(ValueType.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testDeleteKey(P.self)
        try testDeleteKey_Nested(P.self)
        try testDeleteKey_DeleteIfEmpty(P.self)
        try testDeleteKeyNoDictThrows(P.self)
        try testDeleteKey_OnFilter(P.self)
        try testDeleteKey_OnSlice(P.self)

        // index
        try testDeleteIndex(P.self)
        try testDeleteIndex_Nested(P.self)
        try testDeleteIndex_IfEmpty(P.self)
        try testDeleteIndexNoArrayThrows(P.self)
        try testDeleteIndex_OnSlice(P.self)
        try testDeleteIndex_OnFilter(P.self)

        // filter
        try testDeleteFilter(P.self)
        try testDeleteFilter_DeleteIfEmpty(P.self)
        try testDeleteFilter_ThenKey(P.self)
        try testDeleteFilter_ThenIndex(P.self)
        try testDeleteFilter_OnSlice(P.self)
        try testDeleteFilter_OnFilter(P.self)
    }

    func testStub() throws {
        // use this function to launch a specific test with a specific PathExplorer
    }

    // MARK: - Key

    func testDeleteKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Endo": 2, "Toto": 0],
            path: "Endo",
            expected: ["Toto": 0])
    }

    func testDeleteKey_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Endo": ["Toto": 0, "Riri": true]],
            path: "Endo", "Riri",
            expected: ["Endo": ["Toto": 0]])
    }

    func testDeleteKey_DeleteIfEmpty<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Endo": ["Toto": 0]],
            path: "Endo", "Toto",
            deleteIfEmpty: true,
            expected: [:])
    }

    func testDeleteKeyNoDictThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: [1, 2, 3])

        try XCTAssertErrorsEqual(explorer.delete("key"), .subscriptKeyNoDict)
    }

    // MARK: Filter

    func testDeleteKey_OnFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let initialSubDict: ValueType = ["Endo": true, "toto": 2.5]
        let expectedSubDict: ValueType = ["Endo": true]

        try testDelete(
            P.self,
            initial: .filter(["Riri": initialSubDict, "Fifi": initialSubDict, "Loulou": initialSubDict]),
            path: "toto",
            expected: .filter(["Riri": expectedSubDict, "Fifi": expectedSubDict, "Loulou": expectedSubDict]))
    }

    func testDeleteKey_OnSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let initialSubDict: ValueType = ["Endo": true, "toto": 2.5]
        let expectedSubDict: ValueType = ["Endo": true]

        try testDelete(
            P.self,
            initial: .slice([initialSubDict, initialSubDict, initialSubDict]),
            path: "toto",
            expected: .slice([expectedSubDict, expectedSubDict, expectedSubDict]))
    }

    // MARK: - Index

    func testDeleteIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: [1, 2, 3],
            path: 1,
            expected: [1, 3])
    }

    func testDeleteIndex_Nested<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: [[1, 2], [3, 4]],
            path: 1, 0,
            expected: [[1, 2], [4]])
    }

    func testDeleteIndex_IfEmpty<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: [[1, 2], [4]],
            path: 1, 0,
            deleteIfEmpty: true,
            expected: [[1, 2]])
    }

    func testDeleteIndexNoArrayThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        var explorer = P(value: ["Riri": true, "toto": 10])

        try XCTAssertErrorsEqual(explorer.delete(1), .subscriptIndexNoArray)
    }

    func testDeleteIndex_OnSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: .slice([[1, 2, 3], [4, 5, 6], [7, 8, 9]]),
            path: 1,
            expected: .slice([[1, 3], [4, 6], [7, 9]]))
    }

    func testDeleteIndex_OnFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: .filter(["Riri": [1, 2, 3], "Fifi": [1, 2, 3]]),
            path: 0,
            expected: .filter(["Riri": [2, 3], "Fifi": [2, 3]]))
    }

    // MARK: - Filter

    func testDeleteFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Riri": 1, "Fifi": 2, "Loulou": 3],
            path: .filter("Riri|Loulou"),
            expected: ["Fifi": 2])
    }

    func testDeleteFilter_DeleteIfEmpty<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Riri": 1, "Fifi": 2, "Loulou": 3],
            path: .filter(".*"),
            deleteIfEmpty: true,
            expected: [:])
    }

    func testDeleteFilter_ThenKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Riri": ["score": 20.5, "rank": 2], "Fifi": ["score": 20.5, "rank": 2], "Loulou": ["score": 20.5, "rank": 2]],
            path: .filter("Riri|Loulou"), "rank",
            expected: ["Riri": ["score": 20.5], "Fifi": ["score": 20.5, "rank": 2], "Loulou": ["score": 20.5]])
    }

    func testDeleteFilter_ThenIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: ["Riri": [1, 2, 3], "Fifi": [1, 2, 3], "Loulou": [1, 2, 3]],
            path: .filter("Riri|Loulou"), 1,
            expected: ["Riri": [1, 3], "Fifi": [1, 2, 3], "Loulou": [1, 3]])
    }

    func testDeleteFilter_OnSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: .slice([["score": 20.5, "rank": 2], ["score": 20.5, "rank": 2], ["score": 20.5, "rank": 2]]),
            path: .filter("score"),
            expected: .slice([["rank": 2], ["rank": 2], ["rank": 2]]))
    }

    func testDeleteFilter_OnFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testDelete(
            P.self,
            initial: .filter(["Rick": ["score": 20.5, "rank": 2, "rewards": true], "Morty": ["score": 20.5, "rank": 2, "rewards": true]]),
            path: .filter("score|rank"),
            expected: .filter(["Rick": ["rewards": true], "Morty": ["rewards": true]]))
    }
}

extension PathExplorerDeleteTests {

    func testDelete<P: EquatablePathExplorer>(
        _ type: P.Type,
        initial: ValueType,
        path: PathElement...,
        deleteIfEmpty: Bool = false,
        expected: ValueType,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        var explorer = P(value: initial)
        let expectedExplorer = P(value: expected)

        try explorer.delete(path, deleteIfEmpty: deleteIfEmpty)

        XCTAssertExplorersEqual(explorer, expectedExplorer, file: file, line: line)
    }
}
