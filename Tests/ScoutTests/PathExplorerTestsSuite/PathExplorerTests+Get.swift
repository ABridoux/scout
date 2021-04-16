//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerGetTests: XCTestCase {

    // MARK: - Properties

    let woody: ExplorerValue = ["name": "Woody", "catchphrase": "I got a snake in my boot"]
    let buzz: ExplorerValue = ["name": "Buzz", "catchphrase": "To infinity and beyond"]
    let zorg: ExplorerValue = ["name": "Zorg", "catchphrase": "Destroy Buzz Lightyear"]

    // MARK: - Functions

    func testExplorerValue() throws {
        try test(ExplorerValue.self)

        // specific tests for serializable values
        try testGetKey_ThrowsOnNoDictionary(ExplorerValue.self)
        try testGetIndex_ThrowsOnNoArray(ExplorerValue.self)
        try testGetCount_ThrowsOnNonGroup()
        try testGetKeysList_ThrowsOnNonDictionary(ExplorerValue.self)
        try testGetFilter_ThrowsOnNonDictionary(ExplorerValue.self)
        try testGetSlice_ThrowsOnNonArray(ExplorerValue.self)
    }

    func testExplorerXML() throws {
        try test(ExplorerXML.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testGetKey(P.self)
        try testGetKey_MissingThrows(P.self)
        try testGetKey_MissingKeyThrows_BestMatch(P.self)
        try testGetKey_NestedKey(P.self)
        try testGet_MissingNestedKeyThrows(P.self)

        // index
        try testGetIndex(P.self)
        try testGetIndex_LastIndex(P.self)
        try testGetIndex_NegativeIndex(P.self)

        // count
        try testGetArrayCount(P.self)
        try testGetDictionaryCount(P.self)

        // keys list
        try testGetKeysList(P.self)

        // filter
        try testGetFilter(P.self)
        try testGetFilter_ThenKey(P.self)
        try testGetFilter_AfterFilter(P.self)
        try testGetFilter_AfterSlice(P.self)

        // slice
        try testGetSlice(P.self)
        try testGetSlice_ThenIndex(P.self)
        try testGetSlice_AfterSlice(P.self)
        try testGetSlice_AfterFilter(P.self)
    }

    func testStub() throws {
        // use this function to launch a specific test with a specific PathExplorer
    }

    // MARK: - Key

    func testGetKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5])

        try XCTAssertExplorersEqual(explorer.get("Endo"), 2)
        try XCTAssertExplorersEqual(explorer.get("toto"), true)
        try XCTAssertExplorersEqual(explorer.get("Riri"), "duck")
        try XCTAssertExplorersEqual(explorer.get("score"), 12.5)
    }

    func testGetKey_MissingThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5])

        XCTAssertErrorsEqual(try explorer.get("Donald"),
                             .missing(key: "Donald", bestMatch: nil))
    }

    func testGetKey_MissingKeyThrows_BestMatch<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5])

        XCTAssertErrorsEqual(try explorer.get("tata"),
                             ExplorerError.missing(key: "tata", bestMatch: "toto"))
    }

    func testGetKey_NestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["firstKey": ["secondKey": 23]])

        XCTAssertEqual(try explorer.get("firstKey", "secondKey").int, 23)
    }

    func testGet_MissingNestedKeyThrows<P: PathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["firstKey": ["secondKey": 23]])

        XCTAssertErrorsEqual(try explorer.get("firstKey", "kirk"),
                        ExplorerError.missing(key: "kirk", bestMatch: nil).with(path: "firstKey"))
    }

    func testGetKey_ThrowsOnNoDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])

        XCTAssertErrorsEqual(try explorer.get("toto"), .subscriptKeyNoDict)
    }

    // MARK: XML specific

    func testGetKey_XMLAttribute() throws {
        let explorer = ExplorerXML(value: 1).with(attributes: ["toto": "2", "Endo": "true"])
        let expected = ExplorerXML(value: true)

        try XCTAssertExplorersEqual(explorer.get("Endo"), expected)
    }

    // MARK: - Index

    func testGetIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])

        XCTAssertEqual(try explorer.get(0).string, "Endo")
        XCTAssertEqual(try explorer.get(1).int, 1)
        XCTAssertEqual(try explorer.get(2).bool, false)
        XCTAssertEqual(try explorer.get(3).real, 2.5)
    }

    func testGetIndex_LastIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])

        try XCTAssertExplorersEqual(explorer.get(-1), 2.5)
    }

    func testGetIndex_NegativeIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])

        try XCTAssertExplorersEqual(explorer.get(-2), false)
    }

    func testGetIndex_ThrowsOnNoArray<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5])

        XCTAssertErrorsEqual(try explorer.get(1), .subscriptIndexNoArray)
    }

    // MARK: - Count

    func testGetArrayCount<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Endo", 1, false, 2.5],
            path: .count,
            expected: .count(4)
        )
    }

    func testGetDictionaryCount<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5],
            path: .count,
            expected: .count(4)
        )
    }

    func testGetCount_ThrowsOnNonGroup() throws {
        let array: ExplorerValue = ["Endo", 1, false, 2.5]

        XCTAssertErrorsEqual(try array.get(0, .count),
                             ExplorerError.wrongUsage(of: .count).with(path: 0))
    }

    // MARK: - Keys list

    func testGetKeysList<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5],
            path: .keysList,
            expected: .keysList(["Endo", "toto", "Riri", "score"])
        )
    }

    func testGetKeysList_ThrowsOnNonDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])

        XCTAssertErrorsEqual(try explorer.get(.keysList), .wrongUsage(of: .keysList))
    }

    // MARK: - Filter

    func testGetFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Tom": 10, "Robert": true, "Suzanne": "Here"],
            path: .filter("Tom|Robert"),
            expected: .filter(["Tom": 10, "Robert": true])
        )
    }

    func testGetFilter_ThenKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["woody": woody, "buzz": buzz, "zorg": zorg],
            path: .filter("woody|buzz"), "name",
            expected: .filter(["woody_name": "Woody", "buzz_name": "Buzz"])
        )
    }

    func testGetFilter_AfterFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["woody": woody, "buzz": buzz, "zorg": zorg],
            path: .filter("woody|zorg"), .filter("name"),
            expected: .filter(
                ["woody": .filter(["name": "Woody"]),
                 "zorg": .filter(["name": "Zorg"])]
                )
        )
    }

    func testGetFilter_AfterSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: [woody, buzz, zorg],
            path: .slice(0, 1), .filter("name"),
            expected: .slice(
                [.filter(["name": "Woody"]), .filter(["name": "Buzz"])]
            )
        )
    }

    func testGetFilter_ThrowsOnNonDictionary<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Endo", 1, false, 2.5])
        XCTAssertErrorsEqual(try explorer.get(.filter("toto")),
                             .wrongUsage(of: .filter("toto"))
        )
    }

    // MARK: - Slice

    func testGetSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Riri", "Fifi", "Loulou", "Donald", "Daisy"],
            path: .slice(1, -2),
            expected: .slice(["Fifi", "Loulou", "Donald"])
        )
    }

    func testGetSlice_ThenIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: [[1, 2, 3], [4, 5, 6], [7, 8, 9]],
            path: .slice(0, 1), 1,
            expected: .slice([2, 5])
        )
    }

    func testGetSlice_AfterSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["Riri", "Fifi", "Loulou", "Donald", "Daisy"],
            path: .slice(1, -2),
            expected: .slice(["Fifi", "Loulou", "Donald"])
        )
    }

    func testGetSlice_AfterFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        try testGet(
            P.self,
            value: ["first": ["Riri", "Fifi", "Loulou", "Donald", "Daisy"],
                    "second": ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]],
            path: .filter("first"), .slice(1, 2),
            expected: .filter(["first": .slice(["Fifi", "Loulou"])])
        )
    }

    func testGetSlice_ThrowsOnNonArray<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ["Tom": 10, "Robert": true, "Suzanne": "Here"])

        XCTAssertErrorsEqual(try explorer.get(.slice(0, 1)), .wrongUsage(of: .slice(0, 1)))
    }
}

// MARK: - Helpers

extension PathExplorerGetTests {

    func testGet<P: EquatablePathExplorer>(
        _ type: P.Type,
        value: ExplorerValue,
        path: PathElement...,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line)
    throws {
        let explorer = P(value: value)
        let expected = P(value: expected)

        try XCTAssertExplorersEqual(explorer.get(path), expected, file: file, line: line)
    }
}
