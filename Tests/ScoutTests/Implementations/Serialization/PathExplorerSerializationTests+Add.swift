//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import XCTest
@testable import Scout

extension PathExplorerSerializationTests {

    func testAddKeyDict() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)

        try plist.add("Tom", for: "human")

        XCTAssertEqual(try plist.get(for: "human", detailedName: true).string, "Tom")
    }

    func testAddKeyArrayEnd() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks", detailedName: true)

        try plist.add("Donald", for: -1)

        XCTAssertEqual(try plist.get(at: 3, detailedName: true).string, "Donald")
    }

    func testAddKeyArrayInsert() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks", detailedName: true)

        try plist.add("Donald", for: 2)

        XCTAssertEqual(try plist.get(at: 2, detailedName: true).string, "Donald")
    }

    func testAddKey1() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks", -1)

        try plist.add("Donald", at: path)

        XCTAssertEqual(try plist.get(["animals", "ducks", 3]).string, "Donald")
    }

    func testAddKey2() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "mouses", -1)

        try plist.add("Mickey", at: path)

        XCTAssertEqual(try plist.get(["animals", "mouses", 0]).string, "Mickey")
    }

    func testAddKey3() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "mouses", "character")

        try plist.add("Mickey", at: path)

        XCTAssertEqual(try plist.get(["animals", "mouses", "character"]).string, "Mickey")
    }

    func testAddToDictionary_ThrowsIfNonKey() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals")
        let addingPath = path.appending(2)

        XCTAssertErrorsEqual(try plist.add("Daisy", at: addingPath), .dictionarySubscript(path))
    }

    func testAddToArray_ThrowsIfNonIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")
        let addingPath = path.appending("Uncle")

        XCTAssertErrorsEqual(try plist.add("Scrooge", at: addingPath), .arraySubscript(path))
    }

    func testAddToArray_ThrowsIfWrongIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")
        let addingPath = path.appending(4)

        XCTAssertErrorsEqual(try plist.add("Scrooge", at: addingPath), .wrongValueForKey(value: "Scrooge", element: .index(4)))
    }
}
