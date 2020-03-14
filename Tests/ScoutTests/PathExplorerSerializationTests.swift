import XCTest
@testable import PathExplorer

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

        XCTAssertEqual(plist["stringValue"].string, StubPlistStruct().stringValue)
        XCTAssertEqual(plist["intValue"].int, StubPlistStruct().intValue)
    }

    func testSubscriptDictSet() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())
        let newValue = "world"

        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        plist["stringValue"] = PathExplorerSerialization(value: newValue)
        XCTAssertEqual(plist["stringValue"].string, newValue)
    }

    func testSubscriptArray() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)

        let plist = try PathExplorerSerialization<PlistFormat>(data: data)

        XCTAssertEqual(plist[2].string, "cheesecakes")
    }

    func testSubscriptArraySet() throws {
        let array = ["I", "love", "cheesecakes"]
        let data = try PropertyListEncoder().encode(array)
        let newValue = "pies"

        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        plist[2] = PathExplorerSerialization(value: newValue)
        XCTAssertEqual(plist[2].string, newValue)
    }

    func testSubscriptWithVariadic() throws {
        let data = try PropertyListEncoder().encode(StubStruct())

        let plist = try PathExplorerSerialization<PlistFormat>(data: data)

        XCTAssertEqual(plist["animals", "ducks", 1].string, "Fifi")
        XCTAssertEqual(plist["animals"]["ducks"][1].string, "Fifi")
    }

    func testSubscriptWithVariadicSet() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        plist["animals", "ducks", 1] =  PathExplorerSerialization(value: "Donald")

        XCTAssertEqual(plist["animals", "ducks", 1].string, "Donald")
    }

    func testSubscriptWithArray() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        let plist = try PathExplorerSerialization<PlistFormat>(data: data)
        let path: [PathElement] = ["animals", "ducks", 1]

        XCTAssertEqual(plist[path].string, "Fifi")
    }

    func testSubscriptWithArraySet() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try PathExplorerSerialization<PlistFormat>(data: data)

        let path: [PathElement] = ["animals", "ducks", 1]
        plist[path] =  PathExplorerSerialization(value: "Donald")

        XCTAssertEqual(plist["animals", "ducks", 1].string, "Donald")
    }
}
