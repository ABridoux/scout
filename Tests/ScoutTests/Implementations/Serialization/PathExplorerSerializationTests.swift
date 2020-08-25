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

    struct Character: Encodable, Equatable {
        let name: String
        let quote: String
        var episodes = [1, 2, 3]

        static let woody = Character(name: "Woody", quote: "I got a snake in my boot")
        static let buzz = Character(name: "Buzz", quote: "To infinity and beyond")
        static let zurg = Character(name: "Zurg", quote: "Destroy Buzz Lightyear")
    }

    struct StubStruct: Codable {
        let animals = Animals()
    }

    let ducks = ["Riri", "Fifi", "Loulou"]

    let characters: [Character] = [.woody, .buzz, .zurg]

    let temperatures = ["Paris": 23, "Dublin": 19, "Berlin": 21, "Madrid": 26]

    let charactersByName: [String: Character] = ["Woody": .woody, "Buzz": .buzz, "Zurg": .zurg]

    // MARK: - Functions

    func testInit() throws {
        let data = try PropertyListEncoder().encode(StubPlistStruct())

        XCTAssertNoThrow(try Plist(data: data))
    }

    // MARK: Folded

    func testFolded() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)

        plist.fold(upTo: 1)

        let value = try plist.get(0, "episodes", 0).string

        XCTAssertEqual(value, "~~SCOUT_FOLDED~~")
    }

    // MARK: CSV

    func testCSVSingleValues() throws {
        let data = try PropertyListEncoder().encode(ducks)
        let plist = try Plist(data: data)

        let csv = try plist.exportCSV()

        XCTAssertEqual(csv, "Riri;Fifi;Loulou")
    }

    func testCSVArray() throws {
        let data = try PropertyListEncoder().encode(characters)
        let plist = try Plist(data: data)

        let csv = try plist.get(PathElement.slice(Bounds(lower: 0, upper: .last)), "episodes").exportCSVArrayOfArrays(separator: ";")
        let expectedValues = [["1", "2", "3"],
                              ["1", "2", "3"],
                              ["1", "2", "3"]]

        XCTAssertEqual(csv, expectedValues)
    }

    func testCSVArrayOfDictionary() throws {
        let data = try PropertyListEncoder().encode(characters)
        let plist = try Plist(data: data)

        let csv = try plist.exportCSVArrayOfDictionaries(separator: ";")
        let expectedHeaders = ["episodes[0]", "episodes[1]", "episodes[2]", "name", "quote"]
        let expectedValues = [["1", "2", "3", "Woody", "I got a snake in my boot"],
                              ["1", "2", "3", "Buzz", "To infinity and beyond"],
                              ["1", "2", "3", "Zurg", "Destroy Buzz Lightyear"]]

        XCTAssertEqual(csv.headers, expectedHeaders)
        XCTAssertEqual(csv.values, expectedValues)
    }

    func testCSVDictionaryOfArrays() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        let plist = try Plist(data: data)

        let csv = try plist.get(PathElement.filter(".*"), "episodes").exportCSVDictionary(separator: ";")
        let expectedValues = [["Buzz.episodes", "1", "2", "3"],
                              ["Woody.episodes", "1", "2", "3"],
                              ["Zurg.episodes", "1", "2", "3"]]

        XCTAssertEqual(csv.sorted { $0[0] < $1[0] }, expectedValues)
    }

    func testCSVArrayOfArrays() throws {
        let array = [[1, 2, 3],
                     [4, 5, 6],
                     [7, 8, 9]]
        let data = try PropertyListEncoder().encode(array)
        let plist = try Plist(data: data)

        let csv = try plist.exportCSVArray(separator: ";")

        let expected =
        """
        1;2;3
        4;5;6
        7;8;9
        """

        XCTAssertEqual(csv, expected)
    }

    func testExplore() throws {
        let data = try PropertyListEncoder().encode(characters)
        let plist = try Plist(data: data)
        var names = Set<String>()

        plist.exploreGroup(value: plist.value) { (key, _) in
            names.insert(key)
        }

        XCTAssertEqual(names, Set(arrayLiteral: "name", "quote", "episodes[0]", "episodes[1]", "episodes[2]"))
    }
}
