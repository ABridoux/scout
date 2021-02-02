//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerXMLTests {

    func testSubscriptStringSet() throws {
        var xml = try Xml(data: stubData1)

        try xml.set("stringValue", to: "world")

        XCTAssertEqual(try xml.get(for: "stringValue").string, "world")
        XCTAssertEqual(try xml.get(for: "boolValue").bool, false)
    }

    func testSubscriptIntSet() throws {
        var xml = try Xml(data: stubData2)

        try xml.set("dogs", 1, to: "Endo")
        XCTAssertEqual(try xml.get(for: "dogs").get(at: 1).string, "Endo")
    }

    func testSubscriptIntSetLastNegativeIndex() throws {
        var xml = try Xml(data: stubData2)

        try xml.set("dogs", -1, to: "Endo")
        XCTAssertEqual(try xml.get(for: "dogs").get(at: 2).string, "Endo")
    }

    func testSubscriptIntSetNegativeIndex() throws {
        var xml = try Xml(data: stubData2)

        try xml.set("dogs", -3, to: "Endo")
        XCTAssertEqual(try xml.get(for: "dogs").get(at: 0).string, "Endo")
    }

    func testSubscriptArraySet() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("dogs", 1)

        try xml.set(path, to: "Endo")

        XCTAssertEqual(try xml.get(path).string, "Endo")
    }

    func testSetKeyName() throws {
        var xml = try Xml(data: stubData1)

        try xml.set(["stringValue"], keyNameTo: "kiki")

        XCTAssertEqual(try xml.get(for: "kiki").string, "Hello")
    }
}
