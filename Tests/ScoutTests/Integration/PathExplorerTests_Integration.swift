import XCTest
@testable import Scout

final class PathExplorerTestsIntegration: XCTestCase {

    // MARK: - Constants

    let tom: Path = ["people", "Tom"]
    let tomHeight: Path = ["people", "Tom", "height"]
    let tomHobbies: Path = ["people", "Tom", "hobbies"]
    let tomSecondHobby: Path = ["people", "Tom", "hobbies", 1]
    let tomLastHobby: Path = ["people", "Tom", "hobbies", -1]
    let suzanneFirstMovieTitle: Path = ["people", "Suzanne", "movies", 0, "title"]
    let suzanneLastMovieTitle: Path = ["people", "Suzanne", "movies", -1, "title"]

    // MARK: - Properties

    var json: Json!
    var plist: Plist!
    var xml: Xml!

    // MARK: - Setup & Teardown

    override func setUp() {
        do {
            let jsonData = try Data(contentsOf: .peopleJson)
            json = try Json(data: jsonData)

            let plistData = try Data(contentsOf: .peoplePlist)
            plist = try Plist(data: plistData)

            let xmlData = try Data(contentsOf: .peopleXml)
            xml = try Xml(data: xmlData)
        } catch {
            fatalError("Cannot start Integration Tests. \(error.localizedDescription)")
        }
    }

    // MARK: - Functions

    // MARK: Get

    func testGetDictKey() {
        testPathExplorersGet(path: tomHeight, value: 175)
    }

    func testGetArrayIndex() {
        testPathExplorersGet(path: tomSecondHobby, value: "guitar")
    }

    func testGetArrayLastIndex() {
        testPathExplorersGet(path: tomLastHobby, value: "guitar")
    }

    func testGetNestedArrayIndex() {
        testPathExplorersGet(path: suzanneFirstMovieTitle, value: "Tomorrow is so far")
    }

    func testGetNestedArrayLastIndex() {
        testPathExplorersGet(path: suzanneLastMovieTitle, value: "What about today?")
    }

    // -- Helpers

    func testGet<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        do {
            switch value {
            case let stringValue as String:
                let value = try explorer.get(path).string
                XCTAssertEqual(value, stringValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(stringValue)", file: file, line: line)
            case let intValue as Int:
                let value = try explorer.get(path).int
                XCTAssertEqual(value, intValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(intValue)", file: file, line: line)
            case let doubleValue as Double:
                let value = try explorer.get(path).real
                XCTAssertEqual(value, doubleValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(doubleValue)", file: file, line: line)
            case let boolValue as Bool:
                let value = try explorer.get(path).bool
                XCTAssertEqual(value, boolValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(boolValue)", file: file, line: line)
            default:
                assertionFailure("Value not a KeyAllowedType")
            }
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
        }
    }

    func testPathExplorersGet<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testGet(path: path, explorer: json, value: value, file: file, line: line)
        testGet(path: path, explorer: plist, value: value, file: file, line: line)
        testGet(path: path, explorer: xml, value: value, file: file, line: line)
    }

    // MARK: Set

    func testSetDictKey() {
        testPathExplorersSet(path: tomHeight, value: 150)
    }

    func testSetArrayIndex() {
        testPathExplorersSet(path: tomSecondHobby, value: "playing music")
    }

    func testSetArrayLastIndex() {
        testPathExplorersSet(path: tomLastHobby, value: "playing music")
    }

    func testSetNestedArrayIndex() {
        testPathExplorersSet(path: suzanneFirstMovieTitle, value: "Never gonna die")
    }

    func testSetNestedArrayLastIndex() {
        testPathExplorersSet(path: suzanneLastMovieTitle, value: "Never gonna die")
    }

    // -- Helpers

    func testSet<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        do {
            try explorer.set(path, to: value)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        testGet(path: path, explorer: explorer, value: value, file: file, line: line)
    }

    func testPathExplorersSet<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testSet(path: path, explorer: json, value: value, file: file, line: line)
        testSet(path: path, explorer: plist, value: value, file: file, line: line)
        testSet(path: path, explorer: xml, value: value, file: file, line: line)
    }

    // MARK: - Delete

    func testDeleteDictKey() {
        testPathExplorersDelete(path: tomHeight)
    }

    func testDeleteArrayIndex() {
        testPathExplorersDelete(path: tomSecondHobby)
    }

    func testDeleteArrayLastIndex() {
        testPathExplorersDelete(path: tomLastHobby)
    }

    func testDeleteNestedArrayIndex() {
        testPathExplorersDelete(path: suzanneFirstMovieTitle)
    }

    func testDeleteNestedArrayLastIndex() {
        testPathExplorersDelete(path: suzanneLastMovieTitle)
    }

    func testDeleteDict() {
        testPathExplorersDelete(path: tom)
    }

    func testDeleteArray() {
        testPathExplorersDelete(path: tomHobbies)
    }

    // -- Helpers

    func testDelete<Explorer: PathExplorer>(path: Path, explorer: Explorer, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        let value: String
        do {
            value = try explorer.get(path).stringValue
            try explorer.delete(path)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        do {
            let newValue = try explorer.get(path).stringValue
            // if the value was deleted at -1 in an array, the array might still has a last value. So make sure it's not the same
            XCTAssertNotEqual(value, newValue, "\(explorer.format): The value at \(path) has not been deleted", file: file, line: line)
        } catch {
            switch error {
            case PathExplorerError.subscriptWrongIndex, PathExplorerError.subscriptMissingKey:
                return
            default:
                XCTFail("Wrong error for getting a non-exiting value: \(error). Should be 'subscriptWrongIndex' or 'subscriptMissingKey'")
            }
        }
    }

    func testPathExplorersDelete(path: Path, file: StaticString = #file, line: UInt = #line) {
        testDelete(path: path, explorer: json, file: file, line: line)
        testDelete(path: path, explorer: plist, file: file, line: line)
        testDelete(path: path, explorer: xml, file: file, line: line)
    }

    // MARK: Add

    func testAddDictKey() {
        testPathExplorersAdd(path: ["people", "Robert", "secretIdentity"], value: "Bob")
    }

    func testAddArrayIndex() {
        testPathExplorersAdd(path: tomSecondHobby, value: "playing music")
    }

    func testAddArrayLastIndex() {
        testPathExplorersAdd(path: tomLastHobby, value: "playing music")
    }

    func testAddNestedArrayIndex() {
        testPathExplorersSet(path: suzanneFirstMovieTitle, value: "Never gonna die")
    }

    func testAddNestedArrayLastIndex() {
        testPathExplorersSet(path: suzanneLastMovieTitle, value: "Never gonna die")
    }

    func testAddNewDict() {
        testPathExplorersAdd(path: ["people", "Cecil", "secretLove"], value: "Candies")
    }

    func testAddNewArray() {
        testPathExplorersAdd(path: ["people", "Tom", "strengths", 0], value: "Never give up")
    }

    func testAddNewArrayLast() {
        testPathExplorersAdd(path: ["people", "Tom", "strengths", -1], value: "Never give up")
    }

    func testAddNewDictAndArray() {
        testPathExplorersAdd(path: ["people", "Cecil", "secretLoves", 0], value: "Candies")
    }

    // -- Helpers

    func testAdd<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        do {
            try explorer.add(value, at: path)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        testGet(path: path, explorer: explorer, value: value, file: file, line: line)
    }

    func testPathExplorersAdd<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testAdd(path: path, explorer: json, value: value, file: file, line: line)
        testAdd(path: path, explorer: plist, value: value, file: file, line: line)
        testAdd(path: path, explorer: xml, value: value, file: file, line: line)
    }
}
