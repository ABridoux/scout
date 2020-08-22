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
}
