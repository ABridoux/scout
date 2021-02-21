//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerSerializationTests {

    // MARK: - Simple values

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

    func testDeleteLastElement() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks", -1)

        try plist.delete(path)

        XCTAssertEqual(try plist.get("animals", "ducks", 1).string, "Fifi")
        XCTAssertThrowsError(try plist.get("animals", "ducks", 2))
    }

    func testDeleteNegativeIndex() throws {
        let data = try PropertyListEncoder().encode(StubStruct())
        var plist = try Plist(data: data)
        let path = Path("animals", "ducks", -2)

        try plist.delete(path)

        XCTAssertEqual(try plist.get("animals", "ducks", 1).string, "Loulou")
        XCTAssertThrowsError(try plist.get("animals", "ducks", 2))
    }

    func testDeleteLastElement_ThrowsIfEmpty() throws {
        let data = try PropertyListEncoder().encode([String]())
        var plist = try Plist(data: data)
        let path = Path()
        let deletePath = Path(-1)

        XCTAssertErrorsEqual(try plist.delete(deletePath), .subscriptWrongIndex(path: path, index: -1, arrayCount: 0))
    }

    // MARK: - Group values

    // MARK: Array slice

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
        let path = Path(elements: .slice(0, 1), "name")

        try plist.delete(path)

        XCTAssertErrorsEqual(try plist.get(0, "name"), .subscriptMissingKey(path: Path(0), key: "name", bestMatch: nil))
        XCTAssertErrorsEqual(try plist.get(1, "name"), .subscriptMissingKey(path: Path(1), key: "name", bestMatch: nil))
        XCTAssertEqual(try plist.get(2, "name").string, characters[2].name)
    }

    func testDeleteSliceIndex() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(elements: .slice(0, 1), "episodes", 0)

        try plist.delete(path)

        XCTAssertEqual(try plist.get(0, "episodes", PathElement.count).int, 2)
        XCTAssertEqual(try plist.get(1, "episodes", PathElement.count).int, 2)
        XCTAssertEqual(try plist.get(2, "episodes", PathElement.count).int, 3)
    }

    func testDeleteSliceSlice() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(elements: .slice(0, 1), "episodes", .slice(1, 2))

        try plist .delete(path)

        XCTAssertEqual(try plist.get(0, "episodes", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get(1, "episodes", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get(2, "episodes", PathElement.count).int, 3)
    }

    func testDeleteSliceFilter() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(elements: .slice(0, 1), .filter("episodes|quote"))

        try plist .delete(path)

        XCTAssertEqual(try plist.get(0, PathElement.count).int, 1)
        XCTAssertEqual(try plist.get(1, PathElement.count).int, 1)
        XCTAssertEqual(try plist.get(2, PathElement.count).int, 3)
    }

    // MARK: Dictionary filter

    func testDeleteFilter() throws {
        let data = try PropertyListEncoder().encode(temperatures)
        var plist = try Plist(data: data)
        let path: Path = [PathElement.filter("[A-Z]{1}[a-z]*n")]

        try plist.delete(path)

        let resultValue = try XCTUnwrap(plist.value as? [String: Int])
        XCTAssertEqual(["Paris": 23, "Madrid": 26], resultValue)
    }

    func testDeleteArrayStringFilter() throws {
        let data = try PropertyListEncoder().encode(ducks)
        var plist = try Plist(data: data)
        let path = Path(elements: .filter("[A-Z]{1}i[a-z]{1}i"))

        try plist.delete(path)
        let value = plist.value

        let keys = try XCTUnwrap(value as? [String])
        XCTAssertEqual(keys, ["Loulou"])
    }

    func testDeleteDictionaryFilterKey() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(PathElement.filter(".*"), "name")

        try plist.delete(path)
        let value = plist.value

        let keys = try XCTUnwrap(value as? [String: Any])

        XCTAssertEqual(keys.count, 3)

        try characters.forEach { character in
            let dict = try XCTUnwrap(keys[character.name] as? [String: Any])
            XCTAssertEqual(dict.count, 2)
            XCTAssertNil(dict["name"])
        }
    }

    func testDeleteDictionaryFilterIndex() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(PathElement.filter(".*"), "episodes", 1)

        try plist.delete(path)
        let value = plist.value

        let keys = try XCTUnwrap(value as? [String: Any])

        XCTAssertEqual(keys.count, 3)

        try characters.forEach { character in
            let dict = try XCTUnwrap(keys[character.name] as? [String: Any])
            let episodes = try XCTUnwrap(dict["episodes"] as? [Int])
            XCTAssertEqual(episodes, [1, 3])
        }
    }

    func testDeleteFilterSlice() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(PathElement.filter("Woody|Buzz"), "episodes", PathElement.slice(Bounds(lower: 0, upper: 1)))

        try plist.delete(path)

        XCTAssertEqual(try plist.get("Woody", "episodes", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get("Buzz", "episodes", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get("Zurg", "episodes", PathElement.count).int, 3)
    }

    func testDeleteFilterFilter() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(elements: .filter("Woody|Buzz"), .filter("episodes|quote"))

        try plist.delete(path)

        XCTAssertEqual(try plist.get("Woody", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get("Buzz", PathElement.count).int, 1)
        XCTAssertEqual(try plist.get("Zurg", PathElement.count).int, 3)
    }

    // MARK: Delete if empty

    func testDeleteIfEmpty() throws {
        var characters = self.characters
        characters[0].episodes.removeLast(2)

        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(0, "episodes", 0)

        try plist.delete(path, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try plist.get(0, "episodes"), .subscriptMissingKey(path: Path(0), key: "episodes", bestMatch: nil))
    }

    func testDeleteIfEmptyArraySlice() throws {
        var characters = self.characters
        characters[0].episodes.removeLast(1)

        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(0, "episodes", PathElement.slice(Bounds(lower: 0, upper: 1)))

        try plist.delete(path, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try plist.get(0, "episodes"), .subscriptMissingKey(path: Path(0), key: "episodes", bestMatch: nil))
    }

    func testDeleteIfEmptyAfterArraySlice() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(elements: .slice(0, 1), .filter(".*"))

        try plist.delete(path, deleteIfEmpty: true)

        XCTAssertEqual(try plist.get(PathElement.count).int, 1)
    }

    func testDeleteIfEmptyAfterDictionaryFilter() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(PathElement.filter(".*"), "episodes", PathElement.slice(Bounds(lower: 0, upper: 2)))

        try plist.delete(path, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try plist.get("Woody", "episodes"), .subscriptMissingKey(path: Path("Woody"), key: "episodes", bestMatch: nil))
        XCTAssertErrorsEqual(try plist.get("Buzz", "episodes"), .subscriptMissingKey(path: Path("Buzz"), key: "episodes", bestMatch: nil))
        XCTAssertErrorsEqual(try plist.get("Zurg", "episodes"), .subscriptMissingKey(path: Path("Zurg"), key: "episodes", bestMatch: nil))
    }

    // MARK: - Regex pattern

    func testDeleteKeyRegexPattern() throws {
        let attributesKey = "attributes"
        let attributes = ["duration": 20, "score": 500]
        var games = [String: Any]()
        games[attributesKey] = attributes
        var firstPlayer: [String: Any] = ["name": "John", "rank": 1]
        firstPlayer[attributesKey] = attributes
        var secondPlayer: [String: Any] = ["name": "Maeva", "rank": 1]
        secondPlayer[attributesKey] = attributes
        games["players"] = [firstPlayer, secondPlayer]
        var explorer = Plist(value: games)
        let regex = try NSRegularExpression(pattern: "attributes")

        try explorer.delete(regularExpression: regex, deleteIfEmpty: false)

        XCTAssertErrorsEqual(try explorer.get("attributes"), .subscriptMissingKey(path: .empty, key: "attributes", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("players", 0, "attributes"), .subscriptMissingKey(path: Path("players", 0), key: "attributes", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("players", 1, "attributes"), .subscriptMissingKey(path: Path("players", 1), key: "attributes", bestMatch: nil))
    }

    func testDeleteKeyRegexPatternDeleteIfEmpty() throws {
        let attributesKey = "attributes"
        let attributes = ["duration": 20, "score": 500]
        var games = [String: Any]()
        games[attributesKey] = attributes
        let firstPlayer = [attributesKey: attributes]
        let secondPlayer = [attributesKey: attributes]
        games["players"] = [firstPlayer, secondPlayer]
        var explorer = Plist(value: games)
        let regex = try NSRegularExpression(pattern: "attributes")

        try explorer.delete(regularExpression: regex, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try explorer.get("attributes"), .subscriptMissingKey(path: .empty, key: "attributes", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("players"), .subscriptMissingKey(path: .empty, key: "players", bestMatch: nil))
    }
}
