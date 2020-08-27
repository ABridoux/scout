//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerSerializationTests {

    // MARK: - Simple values

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

        XCTAssertErrorsEqual(try plist.getDictAndValueFor(for: "key"), .subscriptMissingKey(path: plist.readingPath, key: "key", bestMatch: nil))
    }

    func testGetDictAndValue_ThrowsIfKeyHasTypoMiswrote() throws {
        let data = try PropertyListEncoder().encode(Animals())

        let plist = try Plist(data: data)

        XCTAssertErrorsEqual(try plist.getDictAndValueFor(for: "docks"), .subscriptMissingKey(path: plist.readingPath, key: "docks", bestMatch: "ducks"))
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

    // MARK: - Group values

    // MARK: Array slice

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

    func testGetArraySliceCount() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("episodes"), .count)

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [Int])
        XCTAssertEqual([3, 3], resultValue)
    }

    func testGetArraySliceArraySlice() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .key("episodes"), .slice(.init(lower: 1, upper: 2)))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [[Int]])
        XCTAssertEqual([[2, 3], [2, 3]], resultValue)
    }

    func testGetArraySliceDictionaryFilter() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .filter(".*(z|Z).*"), .key("episodes"), .slice(.init(lower: 1, upper: 2)))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [String: [Int]])
        XCTAssertEqual(["Buzz_episodes_slice(1,2)": [2, 3], "Zurg_episodes_slice(1,2)": [2, 3]], resultValue)
    }

    func testGetDictionaryFilter() throws {
        let data = try PropertyListEncoder().encode(temperatures)
        let plist = try Plist(data: data)

        let value = try plist.getDictionaryFilter(with: "[A-Z]{1}[a-z]*n").value

        let keys = try XCTUnwrap(value as? [String: Int])
        XCTAssertEqual(keys, ["Dublin": 19, "Berlin": 21])
    }

    func testArrayStringFilter() throws {
        let data = try PropertyListEncoder().encode(ducks)
        let plist = try Plist(data: data)

        let value = try plist.getDictionaryFilter(with: "[A-Z]{1}i[a-z]{1}i").value

        let keys = try XCTUnwrap(value as? [String])
        XCTAssertEqual(keys, ["Riri", "Fifi"])
    }

    // MARK: Dictionary filter

    func testGetDictionaryFilterKey() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        let plist = try Plist(data: data)
        let path = Path(PathElement.filter(".*(z|Z).*"), "name")
        let value = try plist.get(path).value

        let keys = try XCTUnwrap(value as? [String: String])
        var copy = [String: String]()
        charactersByName.forEach { copy[$0.key + "_name"] = $0.value.name }

        copy.removeValue(forKey: "Woody_name")

        XCTAssertEqual(keys, copy)
    }

    func testGetDictionaryFilterIndex() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        let plist = try Plist(data: data)
        let path = Path(PathElement.filter(".*"), "episodes", 1)
        let value = try plist.get(path).value

        let keys = try XCTUnwrap(value as? [String: Int])
        var copy  = [String: Int]()
        charactersByName.forEach { copy[$0.key + "_episodes_index(1)"] = $0.value.episodes[1] }

        XCTAssertEqual(keys, copy)
    }

    func testGetDictionaryCount() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .filter(".*(z|Z).*"), .count)

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [String: Int])
        XCTAssertEqual(["Buzz[#]": 3, "Zurg[#]": 3], resultValue)
    }

    func testGetDictionaryFilterArraySlice() throws {
        let data = try PropertyListEncoder().encode(characters)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .slice(.init(lower: 0, upper: 1)), .filter("episodes"))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [[String: [Int]]])
        XCTAssertEqual([["episodes": [1, 2, 3]], ["episodes": [1, 2, 3]]], resultValue)
    }

    func testGetDictionaryFilterDictionaryFilter() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        var plist = try Plist(data: data)
        let path = Path(pathElements: .filter(".*(z|Z).*"), .filter("episodes"))

        plist = try plist.get(path)

        let resultValue = try XCTUnwrap(plist.value as? [String: [String: [Int]]])
        XCTAssertEqual(["Buzz_filter(episodes)":
                            ["episodes": [1, 2, 3]],
                        "Zurg_filter(episodes)":
                            ["episodes": [1, 2, 3]]],
                       resultValue)
    }

    // MARK: - Array count

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

    // MARK: - Keys list

    func testGetKeysListDict() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        let plist = try Plist(data: data)
        let path: Path = [PathElement.keysList]

        XCTAssertEqual(try plist.get(path).value as? [String], ["Buzz", "Woody", "Zurg"])
    }

    func testGetKeysListSubDict() throws {
        let data = try PropertyListEncoder().encode(charactersByName)
        let plist = try Plist(data: data)
        let path: Path = ["Woody", PathElement.keysList]

        XCTAssertEqual(try plist.get(path).value as? [String], ["episodes", "name", "quote"])
    }
}
