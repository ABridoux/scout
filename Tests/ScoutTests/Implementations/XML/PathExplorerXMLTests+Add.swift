//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerXMLTests {

    func testAddKeyDict() throws {
        var xml = try Xml(data: stubData1)

        try xml.add("2", for: "intValue")

        XCTAssertEqual(try xml.get(for: "intValue").int, 2)
    }

    func testAddKeyArray() throws {
        var xml = try Xml(data: stubData2).get(for: "dogs")

        try xml.add("Endo", for: -1)

        XCTAssertEqual(try xml.get(at: 3).string, "Endo")
    }

    func testAddKeyArrayInsert() throws {
        var xml = try Xml(data: stubData2).get(for: "dogs")

        try xml.add("Endo", for: 1)

        XCTAssertEqual(try xml.get(at: 0).string, "Villy")
        XCTAssertEqual(try xml.get(at: 1).string, "Endo")
        XCTAssertEqual(try xml.get(at: 2).string, "Spot")
        XCTAssertEqual(try xml.get(at: 3).string, "Betty")
    }

    func testAddKey1() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("dogs", -1)

        try xml.add("Endo", at: path)

        XCTAssertEqual(try xml.get(["dogs", 3]).string, "Endo")
    }

    func testAddKey2() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("cats", -1)

        try xml.add("Mocka", at: path)

        XCTAssertEqual(try xml.get(["cats", 0]).string, "Mocka")
    }

    func testAddKey3() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("cats", "my_cat")

        try xml.add("Mocka", at: path)

        XCTAssertEqual(try xml.get(["cats", "my_cat"]).string, "Mocka")
    }
}
