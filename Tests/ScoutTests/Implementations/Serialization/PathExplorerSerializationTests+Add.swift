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

        try plist.add("Donald", for: .count)

        XCTAssertEqual(try plist.get(at: 3, detailedName: true).string, "Donald")
    }

    func testAddKeyArrayNegativeIndex() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks", detailedName: true)

        try plist.add("Donald", for: -2)

        XCTAssertEqual(try plist.get(at: 1, detailedName: true).string, "Donald")
        XCTAssertEqual(try plist.get(at: 2, detailedName: true).string, "Fifi")
    }

    func testAddKeyArrayInsert() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks", detailedName: true)

        try plist.add("Donald", for: 2)

        XCTAssertEqual(try plist.get(at: 2, detailedName: true).string, "Donald")
    }

    func testAddCreateKeyInPath() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path(pathElements: "animals", "ducks", .count)

        try plist.add("Donald", at: path)

        XCTAssertEqual(try plist.get(["animals", "ducks", 3]).string, "Donald")
    }

    func testAddCreateIndexInPath() throws {
        let array: Any = [["title": "firstTitle"], ["title": "secondTitle"], ["title": "thirdTitle"]]
        let data = try JSONSerialization.data(withJSONObject: array)
        var json = try Json(data: data)
        let path = Path(pathElements: .count, "title")

        try json.add("fourthTitle", at: path)

        XCTAssertEqual(try json.get([-1, "title"]).string, "fourthTitle")
    }

    func testAddCreateIndexInEmptyArrayInPath() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path(pathElements: "animals", "mouses", .count, "name")

        try plist.add("Mickey", at: path)

        XCTAssertEqual(try plist.get(["animals", "mouses", -1, "name"]).string, "Mickey")
    }

    func testAddCreateNegativeIndexInPath() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(-2, "friend")

        try plist.add("Woody", at: path)

        XCTAssertEqual(try plist.get(1, "friend").string, "Woody")
    }

    func testAddKey() throws {
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

        XCTAssertErrorsEqual(try plist.add("Daisy", at: addingPath), .wrongElementToSubscript(group: .dictionary, element: 2, path: path))
    }

    func testAddToArray_ThrowsIfNonIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")
        let addingPath = path.appending("Uncle")

        XCTAssertErrorsEqual(try plist.add("Scrooge", at: addingPath), .wrongElementToSubscript(group: .array, element: "Uncle", path: path))
    }

    func testAddToArray_ThrowsIfWrongIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")
        let addingPath = path.appending(4)

        XCTAssertErrorsEqual(try plist.add("Scrooge", at: addingPath), .subscriptWrongIndex(path: path, index: 4, arrayCount: 3))
    }
}
