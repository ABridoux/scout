//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathExplorerGetTests: XCTestCase {

    // MARK: - Properties

    let dict: ValueType = ["Endo": 2, "toto": true, "Riri": "duck", "score": 12.5]
    let nestedDict: ValueType = ["firstKey": ["secondKey": 23]]
    let nestedNestedDict: ValueType = ["firstKey": ["secondKey": ["thirdKey": 23]]]

    let woody: ValueType = ["name": "Woody", "catchphrase": "I got a snake in my boot"]
    let buzz: ValueType = ["name": "Buzz", "catchphrase": "To infinity and beyond"]
    let zorg: ValueType = ["name": "Zorg", "catchphrase": "Destroy Buzz Lightyear"]

    let array: ValueType = ["Endo", 1, false, 2.5]
    let ducks: ValueType = ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
    let matrix3x3: ValueType = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    // MARK: - Functions

    func test() throws {
        try test(ValueType.self)
    }

    func test<P: EquatablePathExplorer>(_ type: P.Type) throws {
        // key
        try testGetKey(P.self)
        try testGetMissingKeyThrows(P.self)
        try testGetMissingKeyThrows_BestMatch(P.self)
        try testGetNestedKey(P.self)
        try testGetMissingNestedKeyThrows(P.self)
        try testGetKeyNoDictionaryThrows_ValueType(P.self)
        try testGetKeyFilter(P.self)

        // index
        try testGetIndex(P.self)
        try testGetLastIndex(P.self)
        try testGetNegativeIndex(P.self)
        try testGetIndexNoArrayThrows(P.self)
        try testGetIndexSlice(P.self)

        // count
        try testGetArrayCount(P.self)
        try testGetDictionaryCount(P.self)
        try testGetCountOnNonGroupThrows()

        // keys list
        try testGetKeysList(P.self)
        try testGetKeysListOnNonDictionaryThrows(P.self)

        // filter
        try testGetFilter(P.self)
        try testGetFilterOfFilter(P.self)
        try testGetFilterOnSlice(P.self)
        try testGetFilterOnNonDictionaryThrows(P.self)

        // slice
        try testGetSlice(P.self)
        try testGetSliceOfSlice(P.self)
        try testGetSliceOnFilter(P.self)
        try testGetSliceOnNonArrayThrows(P.self)
    }

    func testStub() throws {
        // use this function to launch a specific test with a specific PathExplorer
    }

    // MARK: - Key

    func testGetKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)

        try XCTAssertExplorersEqual(explorer.get("Endo"), 2)
        try XCTAssertExplorersEqual(explorer.get("toto"), true)
        try XCTAssertExplorersEqual(explorer.get("Riri"), "duck")
        try XCTAssertExplorersEqual(explorer.get("score"), 12.5)
    }

    func testGetMissingKeyThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)

        XCTAssertErrorsEqual(try explorer.get("Donald"),
                             .missing(key: "Donald", bestMatch: nil))
    }

    func testGetMissingKeyThrows_BestMatch<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)

        XCTAssertErrorsEqual(try explorer.get("tata"),
                             ValueTypeError.missing(key: "tata", bestMatch: "toto"))
    }

    func testGetNestedKey<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: nestedDict)

        XCTAssertEqual(try explorer.get("firstKey", "secondKey").int, 23)
    }

    func testGetMissingNestedKeyThrows<P: PathExplorerBis>(_ type: P.Type) throws {
        let explorer = P(value: nestedDict)

        XCTAssertErrorsEqual(try explorer.get("firstKey", "kirk"),
                        ValueTypeError.missing(key: "kirk", bestMatch: nil).with(path: "firstKey"))
    }

    func testGetKeyNoDictionaryThrows_ValueType<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)

        XCTAssertErrorsEqual(try explorer.get("toto"), .subscriptKeyNoDict)
    }

    // MARK: Filter

    func testGetKeyFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let dict: ValueType = ["woody": woody, "buzz": buzz, "zorg": zorg]
        let expectedOutcome: ValueType = .filter(["woody_name": "Woody", "buzz_name": "Buzz"])

        let explorer = try P(value: dict).get(.filter("woody|buzz"), "name")
        let expectedExplorer = P(value: expectedOutcome)

        XCTAssertExplorersEqual(explorer, expectedExplorer)
    }

    // MARK: - Index

    func testGetIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)

        XCTAssertEqual(try explorer.get(0).string, "Endo")
        XCTAssertEqual(try explorer.get(1).int, 1)
        XCTAssertEqual(try explorer.get(2).bool, false)
        XCTAssertEqual(try explorer.get(3).real, 2.5)
    }

    func testGetLastIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)

        try XCTAssertExplorersEqual(explorer.get(-1), 2.5)
    }

    func testGetNegativeIndex<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)

        try XCTAssertExplorersEqual(explorer.get(-2), false)
    }

    func testGetIndexNoArrayThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)

        XCTAssertErrorsEqual(try explorer.get(1), .subscriptIndexNoArray)
    }

    // MARK: Slice

    func testGetIndexSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: matrix3x3)
        let expectedExplorer = P(value: .slice([2, 5]))

        try XCTAssertExplorersEqual(explorer.get(.slice(0, 1), 1), expectedExplorer)
    }

    // MARK: - Count

    func testGetArrayCount<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)
        let expectedExplorer = P(value: .count(4))

        try XCTAssertExplorersEqual(explorer.get(.count), expectedExplorer)
    }

    func testGetDictionaryCount<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)
        let expectedExplorer = P(value: .count(4))

        try XCTAssertExplorersEqual(explorer.get(.count), expectedExplorer)
    }

    func testGetCountOnNonGroupThrows() throws {
        XCTAssertErrorsEqual(try array.get(0, .count),
                             ValueTypeError.wrongUsage(of: .count).with(path: 0))
    }

    // MARK: - Keys list

    func testGetKeysList<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)
        let expectedExplorer = P(value: .keysList(["Endo", "toto", "Riri", "score"]))

        try XCTAssertExplorersEqual(explorer.get(.keysList), expectedExplorer)
    }

    func testGetKeysListOnNonDictionaryThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)

        XCTAssertErrorsEqual(try explorer.get(.keysList), .wrongUsage(of: .keysList))
    }

    // MARK: - Filter

    func testGetFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let dict: ValueType = ["Tom": 10, "Robert": true, "Suzanne": "Here"]
        let explorer = P(value: dict)
        let expectedExplorer = P(value: .filter(["Tom": 10, "Robert": true]))

        try XCTAssertExplorersEqual(explorer.get(.filter("Tom|Robert")), expectedExplorer)
    }

    func testGetFilterOfFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let dict: ValueType = ["woody": woody, "buzz": buzz, "zorg": zorg]
        let explorer = P(value: dict)
        let expectedOutcome: ValueType = .filter(["woody": .filter(["name": "Woody"]), "zorg": .filter(["name": "Zorg"])])
        let expectedExplorer = P(value: expectedOutcome)

        try XCTAssertExplorersEqual(explorer.get(.filter("woody|zorg"), .filter("name")), expectedExplorer)
    }

    func testGetFilterOnSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let array: ValueType = [woody, buzz, zorg]
        let explorer = P(value: array)
        let expectedOutcome: ValueType = .slice([.filter(["name": "Woody"]), .filter(["name": "Buzz"])])
        let expectedExplorer = P(value: expectedOutcome)

        try XCTAssertExplorersEqual(explorer.get(.slice(0, 1), .filter("name")), expectedExplorer)
    }

    func testGetFilterOnNonDictionaryThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: array)
        XCTAssertErrorsEqual(try explorer.get(.filter("toto")), .wrongUsage(of: .filter("toto")))
    }

    // MARK: - Slice

    func testGetSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: ducks)
        let expectedExplorer = P(value: .slice(["Fifi", "Loulou", "Donald"]))

        try XCTAssertExplorersEqual(explorer.get(.slice(1, -2)), expectedExplorer)
    }

    func testGetSliceOfSlice<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: matrix3x3)
        let expectedExplorer = P(value: .slice([.slice([2, 3]), .slice([5, 6])]))

        try XCTAssertExplorersEqual(explorer.get(.slice(0, 1), .slice(1, 2)), expectedExplorer)
    }

    func testGetSliceOnFilter<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let dict: ValueType = ["first": ducks, "second": ducks]
        let explorer = P(value: dict)
        let expectedOutcome: ValueType = .filter(["first": .slice(["Fifi", "Loulou"])])
        let expectedExplorer = P(value: expectedOutcome)

        try XCTAssertExplorersEqual(explorer.get(.filter("first"), .slice(1, 2)), expectedExplorer)
    }

    func testGetSliceOnNonArrayThrows<P: EquatablePathExplorer>(_ type: P.Type) throws {
        let explorer = P(value: dict)

        XCTAssertErrorsEqual(try explorer.get(.slice(0, 1)), .wrongUsage(of: .slice(0, 1)))
    }
}
