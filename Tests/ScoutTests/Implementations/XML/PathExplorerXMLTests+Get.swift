//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerXMLTests {

    // MARK: - Simple values

    func testSubscriptString() throws {
        let xml = try Xml(data: stubData1)

        XCTAssertEqual(try xml.get(for: "stringValue").string, "Hello")
        XCTAssertEqual(try xml.get(for: "boolValue").bool, false)
    }

    func testSubscriptInt() throws {
        let xml = try Xml(data: stubData2)

        XCTAssertEqual(try xml.get(for: "dogs").get(at: 1).string, "Spot")
    }

    func testSubscriptArray() throws {
        let xml = try Xml(data: stubData2)

        let path = Path("dogs", 1)

        XCTAssertEqual(try xml.get(path).string, "Spot")
    }

    func testSubscriptArrayLastNegativeIndex() throws {
        let xml = try Xml(data: stubData2)

        let path = Path("dogs", -1)

        XCTAssertEqual(try xml.get(path).string, "Betty")
    }

    func testSubscriptArrayNegativeIndex() throws {
        let xml = try Xml(data: stubData2)

        let path = Path("dogs", -2)

        XCTAssertEqual(try xml.get(path).string, "Spot")
    }

    // MARK: - Group values

    // MARK: Array slice

    func testGetArraySlice() throws {
        var xml = try Xml(data: stubData2)

        let path = Path(pathElements: .key("dogs"), .slice(.init(lower: 0, upper: 1)))
        xml = try xml.get(path)

        let resultValue = xml.element.children.map { $0.string }

        XCTAssertEqual(["Villy", "Spot"], resultValue)
    }

    func testGetArraySliceKey() throws {
        var xml = try Xml(data: toyBox)

        let path = Path(pathElements: .key("toybox"), .key("characters"), .slice(.init(lower: 0, upper: 1)), .key("name"))
        xml = try xml.get(path)

        let resultValue = xml.element.children.map { $0.value }

        XCTAssertEqual(resultValue, Character.toybox[0...1].map { $0.name })
    }

    func testGetArraySliceIndex() throws {
        var xml = try Xml(data: toyBox)

        let path = Path(pathElements: .key("toybox"), .key("characters"), .slice(.init(lower: 0, upper: 1)), .key("episodes"), .index(0))
        xml = try xml.get(path)

        let resultValue = xml.element.children.map { $0.int }

        XCTAssertEqual(resultValue, [1, 1])
    }

    func testGetSliceCount() throws {
        var xml = try Xml(data: toyBox)

        xml = try xml.get(["toybox", "characters", PathElement.slice(.init(lower: 0, upper: 1)), "episodes", PathElement.count])

        let resultValue = xml.element.children.map { $0.int }

        XCTAssertEqual(resultValue, [3, 3])
    }

    func testGetSliceGroupSample() throws {
        var xml = try Xml(data: toyBox)

        xml = try xml.get(["toybox", "characters", PathElement.slice(.init(lower: 0, upper: 1)), "episodes", PathElement.slice(Bounds(lower: 0, upper: 1))])

        let resultValue = xml.element.children.flatMap { $0.children }.map { $0.int }

        XCTAssertEqual(resultValue, [1, 2, 1, 2])
    }

    // MARK: Dictionary filter

    func testGetDictionaryFilter() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", PathElement.filter(".*(z|Z).*"))

        let value = try xml.get(path).element

        XCTAssertEqual(value.children.count, 2)
        XCTAssertEqual(value["Buzz"]["name"].string, Character.buzz.name)
        XCTAssertEqual(value["Buzz"]["quote"].string, Character.buzz.quote)
        XCTAssertEqual(value["Zurg"]["name"].string, Character.zurg.name)
        XCTAssertEqual(value["Zurg"]["quote"].string, Character.zurg.quote)
    }

    func testGetDictionaryFilterKey() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", PathElement.filter(".*(z|Z).*"), "quote")
        var value = [String: String]()

        try xml.get(path).element.children.forEach { value[$0.name] = $0.value }

        var quotes = [String: String]()
        Character.charactersByName.forEach { quotes[$0.key + "_quote"] = $0.value.quote }
        quotes.removeValue(forKey: "Woody_quote")

        XCTAssertEqual(quotes, value)
    }

    func testGetDictionaryFilterIndex() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", PathElement.filter(".*(z|Z).*"), "episodes", 1)
        var value = [String: Int]()

        try xml.get(path).element.children.forEach { value[$0.name] = $0.int }

        var episodes = [String: Int]()
        Character.charactersByName.forEach { episodes[$0.key + "_episodes_index(1)"] = $0.value.episodes[1] }
        episodes.removeValue(forKey: "Woody_episodes_index(1)")

        XCTAssertEqual(episodes, value)
    }

    func testGetFilterGroupSample() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", PathElement.filter(".*(z|Z).*"), PathElement.filter("episodes"))

        let element = try xml.get(path).element

        XCTAssertEqual(element["Buzz_filter(episodes)"]["episodes"].children.count, 3)
        XCTAssertEqual(element["Zurg_filter(episodes)"]["episodes"].children.count, 3)
    }

    // MARK: Array count

    func testGetCount() throws {
        let xml = try Xml(data: stubData2)

        XCTAssertEqual(try xml.get(for: "dogs").get(element: .count).int, 3)
    }

    func testGetCountDictionaryFilter() throws {
        let xml = try Xml(data: toyBoxByName)

        let element = try xml.get("characters", PathElement.filter(".*"), PathElement.count).element

        XCTAssertEqual(element["Woody_count"].int, 3)
        XCTAssertEqual(element["Buzz_count"].int, 3)
        XCTAssertEqual(element["Zurg_count"].int, 3)
    }

    func testGetCount_ThrowsErrorIfNotFinal() throws {
        let xml = try Xml(data: stubData2)
        let errorPath = Path("root", "dogs", PathElement.count)
        let path = errorPath.appending(2)

        XCTAssertErrorsEqual(try xml.get(path), .wrongUsage(of: .count, in: errorPath))
    }

    func testSetCount_ThrowsError() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("root", "dogs", PathElement.count)

        XCTAssertErrorsEqual(try xml.set(path, to: "Woomy"), .wrongUsage(of: .count, in: path))
    }

    func testSetKeyNameCount_ThrowsError() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("root", "dogs", PathElement.count)

        XCTAssertErrorsEqual(try xml.set(path, keyNameTo: "Woomy"), .wrongUsage(of: .count, in: path))
    }

    func testDeleteCount_ThrowsError() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("root", "dogs", PathElement.count)

        XCTAssertErrorsEqual(try xml.delete(path), .wrongUsage(of: .count, in: path))
    }

    // MARK: - Keys list

    func testGetKeysListDict() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", PathElement.keysList)

        let element = try xml.get(path).element

        let names = ["Buzz", "Woody", "Zurg"]

        XCTAssertEqual(element.name, "characters{#}")
        for i in 0...2 {
            XCTAssertEqual(element.children[i].name, "key")
            XCTAssertEqual(element.children[i].string, names[i])
        }
    }

    func testGetKeysListSubDict() throws {
        let xml = try Xml(data: toyBoxByName)
        let path = Path("toybox", "characters", "Woody", PathElement.keysList)

        let element = try xml.get(path).element

        let names = ["episodes", "name", "quote"]

        for i in 0...2 {
            XCTAssertEqual(element.children[i].name, "key")
            XCTAssertEqual(element.children[i].string, names[i])
        }
    }
}
