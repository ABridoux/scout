//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import Scout

final class PathExplorerTestsIntegration: XCTestCase {

    // MARK: - Constants

    let tom: Path = ["Tom"]
    let tomHeight: Path = ["Tom", "height"]
    let tomHobbies: Path = ["Tom", "hobbies"]
    let tomSecondHobby: Path = ["Tom", "hobbies", 1]
    let tomLastHobby: Path = ["Tom", "hobbies", -1]
    let tomAddLastHobby: Path = ["Tom", "hobbies", PathElement.count]
    let suzanneFirstMovieTitle: Path = ["Suzanne", "movies", 0, "title"]
    let suzanneLastMovieTitle: Path = ["Suzanne", "movies", -1, "title"]
    let robertRunningRecordsSecondFirst: Path = ["Robert", "running_records", 1, 0]

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

    func testGetNestedArrayInArrayIndex() {
        testPathExplorersGet(path: robertRunningRecordsSecondFirst, value: 9)
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

    func testSetNestedArrayInArrayIndex() {
        testPathExplorersSet(path: robertRunningRecordsSecondFirst, value: 25)
    }

    func setKeyName() {
        testPathExplorersSet(path: tomHeight, keyName: "centimer")
    }

    // MARK: Delete

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

    func testDeleteNestedArrayInArrayIndex() {
        testPathExplorersDelete(path: robertRunningRecordsSecondFirst)
    }

    // MARK: Add

    func testAddDictKey() {
        testPathExplorersAdd(path: ["people", "Robert", "secretIdentity"], value: "Bob")
    }

    func testAddArrayIndex() {
        testPathExplorersAdd(path: tomSecondHobby, value: "playing music")
    }

    func testAddArrayLastIndex() {
        testPathExplorersAdd(path: tomAddLastHobby, value: "playing music")
    }

    func testAddNestedArrayIndex() {
        // adding value to an existing key should act like setting it
        testPathExplorersAdd(path: suzanneFirstMovieTitle, value: "Never gonna die")
    }

    func testAddNestedArrayLastIndex() {
        testPathExplorersAdd(path: suzanneLastMovieTitle, value: "Never gonna die")
    }

    func testAddNewDict() {
        testPathExplorersAdd(path: ["people", "Cecil", "secretLove"], value: "Candies")
    }

    func testAddNewArray() {
        testPathExplorersAdd(path: ["people", "Tom", "strengths", 0], value: "Never give up")
    }

    func testAddNewArrayLast() {
        testPathExplorersAdd(path: ["people", "Tom", "strengths", PathElement.count], value: "Never give up")
    }

    func testAddNewDictAndArray() {
        testPathExplorersAdd(path: ["people", "Cecil", "secretLoves", 0], value: "Candies")
    }

    func testAddNestedArrayInArray() {
        testPathExplorersAdd(path: ["people", "Robert", "running_records", 0, PathElement.count], value: 30)
    }

    func testAddNestedArrayTwoLevels() {
        testPathExplorersAdd(path: ["people", "Robert", "running_records", 0, PathElement.count], value: 25)
    }
}
