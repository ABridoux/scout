//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class ValueTypeGetTests: XCTestCase {

    typealias ValueTypeJson = ValueType<CodableFormats.Json>

    let dict: ValueTypeJson = ["firstKey": 2, "secondKey": "Endo"]
    let nestedDict: ValueTypeJson = ["firstKey": ["secondKey": 23]]
    let nestedNestedDict: ValueTypeJson = ["firstKey": ["secondKey": ["thirdKey": 23]]]

    let woody: ValueTypeJson = ["name": "Woody", "catchphrase": "I got a snake in my boot"]
    let buzz: ValueTypeJson = ["name": "Buzz", "catchphrase": "To infinity and beyond"]
    let zorg: ValueTypeJson = ["name": "Zorg", "catchphrase": "Destroy Buzz Lightyear"]

    let array: ValueTypeJson = [2, "Endo"]
    let ducks: ValueTypeJson = ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
    let matrix3x3: ValueTypeJson = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

    // MARK: - Key

    func testGetKey() throws {
        XCTAssertEqual(try dict.get("firstKey"), 2)
        XCTAssertEqual(try dict.get("secondKey"), "Endo")
    }

    func testGetMissingKeyThrows() throws {
        XCTAssertErrorsEqual(try dict.get("toto"),
                             ValueTypeError.missing(key: "toto", bestMatch: nil))
    }

    func testGetMissingKeyThrows_BestMatch() throws {
        XCTAssertErrorsEqual(try dict.get("firstKuy"),
                             ValueTypeError.missing(key: "firstKuy", bestMatch: "firstKey"))
    }

    func testGetNestedKey() throws {
        XCTAssertEqual(try nestedDict.get("firstKey", "secondKey"), 23)
    }

    func testGetMissingNestedKeyThrows() throws {
        XCTAssertErrorsEqual(try nestedDict.get("firstKey", "kirk"),
                             ValueTypeError.missing(key: "kirk", bestMatch: nil).with(path: "firstKey"))
    }

    func testGetMissingNestedNestedKey_Throws() throws {
        XCTAssertErrorsEqual(try nestedNestedDict.get("firstKey", "secondKey" , "kirk"),
                             ValueTypeError.missing(key: "kirk", bestMatch: nil).with(path: "secondKey", "firstKey"))
    }

    func testGetKeyNoDictionaryThrows() throws {
        XCTAssertErrorsEqual(try array.get("toto"), ValueTypeError.subscriptKeyNoDict)
    }

    // MARK: Dictionary filter

    func testGetKeyFilter() throws {
        let dict: ValueTypeJson = ["woody": woody, "buzz": buzz, "zorg": zorg]

        XCTAssertEqual(try dict.get(.filter("woody|buzz"), "name"), .filter(["woody_name": "Woody", "buzz_name": "Buzz"]))
    }

    // MARK: - Index

    func testGetIndex() throws {
        XCTAssertEqual(try array.get(0), 2)
        XCTAssertEqual(try array.get(1), "Endo")
    }

    func testGetLastIndex() throws {
        XCTAssertEqual(try array.get(-1), "Endo")
    }

    func testGetNegativeIndex() throws {
        XCTAssertEqual(try array.get(-2), 2)
    }

    func testGetIndexOutOfBoundsThrows() throws {
        XCTAssertErrorsEqual(try array.get(2), ValueTypeError.wrong(index: 2, arrayCount: 2))
    }

    func testGetNegativeIndexOutOfBoundsThrows() throws {
        XCTAssertErrorsEqual(try array.get(-3), ValueTypeError.wrong(index: -3, arrayCount: 2))
    }

    func testGetIndexNoArrayThrows() throws {
        XCTAssertErrorsEqual(try dict.get(1), ValueTypeError.subscriptIndexNoArray)
    }

    // MARK: Array slice

    func testGetIndexSlice() throws {
        XCTAssertEqual(try matrix3x3.get(.slice(0, 1), 1), .slice([2, 5]))
    }

    // MARK: - Count

    func testGetArrayCount() throws {
        XCTAssertEqual(try array.get(.count), .count(2))
    }

    func testGetDictionaryCount() throws {
        XCTAssertEqual(try dict.get(.count), .count(2))
    }

    func testGetCountOnNonGroupThrows() throws {
        let array: ValueTypeJson = [1, 2, 3]
        XCTAssertErrorsEqual(try array.get(0, .count), ValueTypeError.wrongUsage(of: .count).with(path: 0))
    }

    // MARK: - KeysList

    func testGetKeysList() throws {
        XCTAssertEqual(try dict.get(.keysList), .keysList(["firstKey", "secondKey"]))
    }

    func testGetKeysListOnNonDictionaryThrows() throws {
        XCTAssertErrorsEqual(try array.get(.keysList), ValueTypeError.wrongUsage(of: .keysList))
    }

    // MARK: - Dictionary filter

    func testGetFilter() throws {
        let dict: ValueTypeJson = ["Tom": 10, "Robert": true, "Suzanne": "Here"]

        XCTAssertEqual(try dict.get(.filter("Tom|Robert")), .filter(["Tom": 10, "Robert": true]))
    }

    func testGetFilterOfDictionaryFilter() throws {
        let dict: ValueTypeJson = ["woody": woody, "buzz": buzz, "zorg": zorg]

        XCTAssertEqual(try dict.get(.filter("woody|zorg"), .filter("name")),
                       .filter(["woody": .filter(["name": "Woody"]), "zorg": .filter(["name": "Zorg"])]))
    }

    func testGetFilterOnNonDictionaryThrows() throws {
        XCTAssertErrorsEqual(try array.get(.filter("toto")), .wrongUsage(of: .filter("toto")))
    }

    func testGetFilterOnSlice() throws {
        let array: ValueTypeJson = [woody, buzz, zorg]

        XCTAssertEqual(try array.get(.slice(0, 1), .filter("name")),
                       .slice(
                            [.filter(["name": "Woody"]),
                            .filter(["name": "Buzz"])]
                       )
        )
    }

    // MARK: - Array slice

    func testGetSlice() throws {
        XCTAssertEqual(try ducks.get(.slice(1, -2)), .slice(["Fifi", "Loulou", "Donald"]))
    }

    func testGetSliceOfSlice() throws {
        XCTAssertEqual(try matrix3x3.get(.slice(0, 1), .slice(1, 2)),
                       .slice(
                            [.slice([2, 3]), .slice([5, 6])]
                       )
        )
    }

    func testGetSliceOnNonArrayThrows() throws {
        XCTAssertErrorsEqual(try dict.get(.slice(0, 1)), .wrongUsage(of: .slice(0, 1)))
    }

    func testGetSliceOnFilter() throws {
        let dict: ValueTypeJson = ["first": ducks, "second": ducks]

        XCTAssertEqual(try dict.get(.filter("first"), .slice(1, 2)),
                       .filter(
                            ["first": .slice(["Fifi", "Loulou"])]
                       )
        )
    }
}
