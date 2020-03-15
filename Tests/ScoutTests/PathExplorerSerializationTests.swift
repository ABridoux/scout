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

    struct StubStruct: Codable {
        let animals = Animals()
    }

    // MARK: - Functions

    func testInit() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())

        XCTAssertNoThrow(try PathExplorerSerialization<PlistFormat>(data: data))
    }

    func testSubscriptDict() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())

        let plist = try PathExplorerSerialization<PlistFormat>(data: data)

        XCTAssertEqual(try plist.get(for: "stringValue").string, StubPlistStruct().stringValue)
        XCTAssertEqual(try plist.get(for: "intValue").int, StubPlistStruct().intValue)
    }

    func testSubscriptDictSet() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())
        let newValue = "world"

        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        try plist.set(key: "stringValue", to: newValue)
        XCTAssertEqual(try plist.get(for: "stringValue").string, newValue)
    }

    func testSubscriptArray() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)

        let plist = try PathExplorerSerialization<PlistFormat>(data: data)

        XCTAssertEqual(try plist.get(at: 2).string, "cheesecakes")
    }

    func testSubscriptArraySet() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)
        let newValue = "pies"

        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        try plist.set(index: 2, to: newValue)
        XCTAssertEqual(try plist.get(at: 2).string, newValue)
    }

    func testSubscriptWithArray() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        let plist = try PathExplorerSerialization<PlistFormat>(data: data)
        let path: [PathElement] = ["animals", "ducks", 1]

        XCTAssertEqual(try plist.get(path).string, "Fifi")
    }

    func testSubscriptWithArraySet() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try PathExplorerSerialization<PlistFormat>(data: data)
        let newValue = "Donald"

        let path: [PathElement] = ["animals", "ducks", 1]
        try plist.set(path, to: newValue)

        XCTAssertEqual(try plist.get(path).string, newValue)
    }

    func testSetKeyName() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try PathExplorerSerialization<PlistFormat>(data: data)
        let path: [PathElement] = ["animals", "ducks"]

        try plist.set(path, keyNameTo: "children_ducks")

        XCTAssertEqual(try plist.get(["animals", "children_ducks", 1]).string, "Fifi")
    }

    func testDeleteKey() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try PathExplorerSerialization<PlistFormat>(data: data)
        let path: [PathElement] = ["animals", "ducks", 1]

        try plist.delete(path)

        XCTAssertEqual(try plist.get("animals", "ducks", 1).string, "Loulou")
        XCTAssertThrowsError(try plist.get("animals", "ducks", 2))
    }
}
