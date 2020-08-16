//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

final class PathExplorerSerializationTests: XCTestCase {

    // MARK: - Constants

    struct StubPlistStruct: Codable {
        let stringValue = "Hello"
        let intValue = 1
    }

    struct Animals: Codable {
        let ducks = ["Riri", "Fifi", "Loulou"]
    }

    struct Character: Encodable {
        let name: String
        let quote: String
        let episodes = [1, 2, 3]
    }

    struct StubStruct: Codable {
        let animals = Animals()
    }

    let ducks = ["Riri", "Fifi", "Loulou"]

    let characters = [Character(name: "Woody", quote: "I got a snake in my boot"),
                      Character(name: "Buzz", quote: "To infinity and beyond"),
                      Character(name: "Zurg", quote: "Destroy Buzz Lightyear")]

    // MARK: - Functions

    func testInit() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())

        XCTAssertNoThrow(try Plist(data: data))
    }

    // MARK: Get

    func testSubscriptDict() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())

        let plist = try Plist(data: data)

        XCTAssertEqual(try plist.get(for: "stringValue").string, StubPlistStruct().stringValue)
        XCTAssertEqual(try plist.get(for: "intValue").int, StubPlistStruct().intValue)
    }

    func testSubscriptDict_ThrowsIfNotDict() throws {
        let data = try PropertyListEncoder().encode(ducks)

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.get("key"), .dictionarySubscript(plist.readingPath))
    }

    func testGetDictAndValue_ThrowsIfKeyNotExists() throws {
        let data = try PropertyListEncoder().encode(Animals())

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.getDictAndValueFor(key: "key"), .subscriptMissingKey(path: plist.readingPath, key: "key", bestMatch: nil))
    }

    func testGetDictAndValue_ThrowsIfKeyHasTypoMiswrote() throws {
        let data = try PropertyListEncoder().encode(Animals())

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.getDictAndValueFor(key: "docks"), .subscriptMissingKey(path: plist.readingPath, key: "docks", bestMatch: "ducks"))
    }

    func testSubscriptArray() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)

        let plist = try Plist(data: data)

        XCTAssertEqual(try plist.get(at: 2).string, "cheesecakes")
    }

    func testSubscriptArray_ThrowsIfNotArray() throws {
        let data = try PropertyListEncoder().encode(Animals())

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.get(1), .arraySubscript(plist.readingPath))
    }

    func testSubscriptArray_ThrowsIfWrongIndex() throws {
        let data = try PropertyListEncoder().encode(ducks)

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.get(4), .subscriptWrongIndex(path: plist.readingPath, index: 4, arrayCount: 3))
    }

    func testSubscriptWithArray() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        let plist = try Plist(data: data)
        let path = Path("animals", "ducks", 1)

        XCTAssertEqual(try plist.get(path).string, "Fifi")
    }

    func testDecodeRootArray() throws {
        let data = try PropertyListEncoder().encode(ducks)
        let plist = try Plist(data: data)
        let second = Path(1)
        let last = Path(-1)

        XCTAssertEqual(try plist.get(second).string, "Fifi")
        XCTAssertEqual(try plist.get(last).string, "Loulou")
    }

    func testGetArraySlice() throws {
        let data = try PropertyListEncoder().encode(ducks)
        var plist = try Plist(data: data)
        let path: Path = [PathElement.slice(.init(lower: 0, upper: 1))]

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [String])
        XCTAssertEqual(Array(ducks[0...1]), resultValue)
    }

    func testGetArraySliceKey() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("name"))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [String])
        XCTAssertEqual(Array(characters[0...1].map { $0.name }), resultValue)
    }

    func testGetArraySliceIndex() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("episodes"), .index(1))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [Int])
        XCTAssertEqual(Array(characters[0...1].map { $0.episodes[1] }), resultValue)
    }

    // MARK: Set

    func testSubscriptDictSet() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())
        let newValue = "world"

        var plist = try Plist(data: data)

        try plist.set(key: "stringValue", to: newValue)
        XCTAssertEqual(try plist.get(for: "stringValue").string, newValue)
    }

    func testSubscriptArraySet() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)
        let newValue = "pies"

        var plist = try Plist(data: data)

        try plist.set(index: 2, to: newValue)
        XCTAssertEqual(try plist.get(at: 2).string, newValue)
    }

    func testSubscriptWithArraySet() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let newValue = "Donald"

        let path = Path("animals", "ducks", 1)
        try plist.set(path, to: newValue)

        XCTAssertEqual(try plist.get(path).string, newValue)
    }

    func testSetKeyName() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")

        try plist.set(path, keyNameTo: "children_ducks")

        XCTAssertEqual(try plist.get(["animals", "children_ducks", 1]).string, "Fifi")
    }

    func testSet_ThrowsIfPathElementIsDictionaryOrArray() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path(arrayLiteral: "animals", "ducks")

        XCTAssertErrorsEqual(try plist.set(path, to: "Donald"), .wrongValueForKey(value: "Donald", element: .key("ducks")))
    }

    func testSetKey_ThrowsIfNotDictionary() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path(arrayLiteral: "animals", "ducks", 2)

        XCTAssertErrorsEqual(try plist.set(path, keyNameTo: "Donald"), .keyNameSetOnNonDictionary(path: path))
    }

    // MARK: Delete

    func testDeleteKey() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks", 1)

        try plist.delete(path)

        XCTAssertEqual(try plist.get("animals", "ducks", 1).string, "Loulou")
        XCTAssertThrowsError(try plist.get("animals", "ducks", 2))
    }

    func testDelete_ThrowsIfWrongIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks")
        let deletePath = path.appending(4)

        XCTAssertErrorsEqual(try plist.delete(deletePath), .subscriptWrongIndex(path: path, index: 4, arrayCount: 3))
    }

    func testDeleteLastElement_ThrowsIfEmpty() throws {
        let data = try PropertyListEncoder().encode([String]())
        var plist = try Plist(data: data)
        let path = Path()
        let deletePath = Path(-1)

        XCTAssertErrorsEqual(try plist.delete(deletePath), .subscriptWrongIndex(path: path, index: -1, arrayCount: 0))
    }

    func testDeleteSlice() throws {
        let data = try PropertyListEncoder().encode(ducks)
        var plist = try Plist(data: data)
        let path: Path = [PathElement.slice(.init(lower: 0, upper: 1))]

        try plist.delete(path)

        let resultValue = try XCTUnwrap(plist.value as? [String])
        XCTAssertEqual(Array(ducks[2...2]), resultValue)
    }

    func testDeleteSliceKey() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("name"))

        try plist.delete(path)

        XCTAssertErrorsEqual(try plist.get(0, "name"), .subscriptMissingKey(path: Path(0), key: "name", bestMatch: nil))
        XCTAssertErrorsEqual(try plist.get(1, "name"), .subscriptMissingKey(path: Path(1), key: "name", bestMatch: nil))
        XCTAssertEqual(try plist.get(2, "name").string, characters[2].name)
    }

    func testDeleteSliceIndex() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("episodes"), .index(0))

        try plist.delete(path)

        XCTAssertEqual(try plist.get(0, "episodes", PathElement.count).int, 2)
        XCTAssertEqual(try plist.get(1, "episodes", PathElement.count).int, 2)
        XCTAssertEqual(try plist.get(2, "episodes", PathElement.count).int, 3)
    }

    // MARK: Add

    func testAddKeyDict() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)

        try plist.add("Tom", for: "human")

        XCTAssertEqual(try plist.get(for: "human").string, "Tom")
    }

    func testAddKeyArrayEnd() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks")

        try plist.add("Donald", for: -1)

        XCTAssertEqual(try plist.get(at: 3).string, "Donald")
    }

    func testAddKeyArrayInsert() throws {
        let data = try PropertyListEncoder().encode(Animals())
        var plist = try Plist(data: data).get(for: "ducks")

        try plist.add("Donald", for: 2)

        XCTAssertEqual(try plist.get(at: 2).string, "Donald")
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

    // MARK: Array count

    func testGetCount() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        let plist = try Plist(data: data)
        let path: Path = ["animals", "ducks", PathElement.count]

        let arrayCount = try plist.get(path).int

        XCTAssertEqual(arrayCount, 3)
    }

    func testGetCount_ThrowsErrorIfNotFinal() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        let plist = try Plist(data: data)
        let errorPath: Path = ["animals", "ducks", PathElement.count]
        let path = errorPath.appending(1)

        XCTAssertErrorsEqual(try plist.get(path), .wrongUsage(of: .count, in: errorPath))
    }

    func testSetCount_ThrowsError() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path: Path = ["animals", "ducks", PathElement.count]

        XCTAssertErrorsEqual(try plist.set(path, to: "Woomy"), .wrongUsage(of: .count, in: path))
    }

    func testSetKeyNameCount_ThrowsError() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path: Path = ["animals", "ducks", PathElement.count]

        XCTAssertErrorsEqual(try plist.set(path, keyNameTo: "Woomy"), .keyNameSetOnNonDictionary(path: path))
    }

    func testDeleteCount_ThrowsError() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path: Path = ["animals", "ducks", PathElement.count]

        XCTAssertErrorsEqual(try plist.delete(path), .wrongUsage(of: .count, in: path))
    }

    func testAddCount_ThrowsError() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path: Path = ["animals", "ducks", PathElement.count]

        XCTAssertErrorsEqual(try plist.add("Woomy", at: path), .wrongUsage(of: .count, in: path))
    }
}
