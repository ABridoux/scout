//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

final class ValueTypeSetTests: XCTestCase {

    var dict: ValueType!
    var array: ValueType!

    override func setUp() {
        dict = ["toto": 2, "Endo": false]
        array = [1, false, "toto"]
    }

    // MARK: - Key

    func testSetKey() throws {
        var dict: ValueType = ["toto": 2, "Endo": false]

        try dict.set("toto", to: 3.5)

        XCTAssertEqual(dict, ["toto": 3.5, "Endo": false])
    }

    func testSetNestedKey() throws {
        var dict: ValueType = ["toto": ["Riri": 2], "Endo": false]

        try dict.set("toto", "Riri", to: 3.5)

        XCTAssertEqual(dict, ["toto": ["Riri": 3.5], "Endo": false])
    }

    func testSetKeyOnNonDictionaryThrows() throws {
        XCTAssertErrorsEqual(try array.set("toto", to: 1), .subscriptKeyNoDict)
    }

    func testSetKeyOnNonDictionaryThrows_Nested() throws {
        var dict: ValueType = ["toto": [true]]

        XCTAssertErrorsEqual(try dict.set("toto", "Endo", to: 1),
                             ValueTypeError.subscriptKeyNoDict.with(path: "toto"))
    }

    // MARK: - Index

    func testSetIndex() throws {
        try array.set(1, to: 2.3)

        XCTAssertEqual(array, [1, 2.3, "toto"])
    }

    func testSetNegativeIndex() throws {
        try array.set(-2, to: 2.3)

        XCTAssertEqual(array, [1, 2.3, "toto"])
    }

    func testSetIndexOnNonArrayThrows() throws {
        XCTAssertErrorsEqual(try dict.set(1, to: 2), .subscriptIndexNoArray)
    }

    func testSetIndexOnNonArrayThrows_Nested() throws {
        var array: ValueType = [["Endo": 2]]

        XCTAssertErrorsEqual(try array.set(0, 1, to: 2),
                             ValueTypeError.subscriptIndexNoArray.with(path: 0))
    }

    // MARK: Key name

    func testSetKeyName_Key() throws {
        try dict.set("toto", keyNameTo: "tata")

        XCTAssertEqual(dict, ["tata": 2, "Endo": false])
    }
}
