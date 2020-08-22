//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
@testable import Scout

extension PathExplorerXMLTests {

    func testDelete() throws {
        var xml = try Xml(data: stubData2)

        try xml.delete(["dogs", 1])

        XCTAssertEqual(try xml.get("dogs", 1).string, "Betty")
        XCTAssertThrowsError(try xml.get("dogs", 2))
    }

    // MARK: - Group samples

    // MARK: Array slice

    func testDeleteSlice() throws {
        var xml = try Xml(data: stubData2)

        try xml.delete(["dogs", PathElement.slice(.init(lower: 0, upper: 1))])

        let resultValue = xml.element.children.first?.children.map { $0.string }
        XCTAssertEqual(resultValue, ["Betty"])
    }

    func testDeleteSliceKey() throws {
        var xml = try Xml(data: toyBox)

        try xml.delete(["toybox", "characters", PathElement.slice(.init(lower: 0, upper: 1)), "episodes"])

        for index in 0...1 {
            let path = Path("toybox", "characters", index)
            XCTAssertErrorsEqual(try xml.get(path.appending("episodes")), .subscriptMissingKey(path: path, key: "episodes", bestMatch: nil))
        }
    }

    func testDeleteSliceIndex() throws {
        var xml = try Xml(data: toyBox)

        try xml.delete(["toybox", "characters", PathElement.slice(.init(lower: 0, upper: 1)), "episodes", 1])

        let path = Path("toybox", "characters", 0, "episodes")
        XCTAssertErrorsEqual(try xml.get(path.appending("episodes", 2)), .subscriptWrongIndex(path: path, index: 2, arrayCount: 2))
    }

    // MARK: Dictionary filter

    func testDeleteDictionaryFilter() throws {
        var xml = try Xml(data: toyBoxByName)

        try xml.delete("characters", PathElement.filter(".*(z|Z).*"))

        XCTAssertEqual(xml.element.children.count, 1)
        XCTAssertEqual(xml.element["characters"].children.first?.name, "Woody")
    }

    func testDeleteDictionaryFilterKey() throws {
        var xml = try Xml(data: toyBoxByName)

        try xml.delete("characters", PathElement.filter(".*(z|Z).*"), "episodes")

        XCTAssertEqual(xml.element["characters"]["Woody"].children.count, 3)
        XCTAssertEqual(xml.element["characters"]["Zurg"].children.count, 2)
        XCTAssertEqual(xml.element["characters"]["Buzz"].children.count, 2)
    }

    func testDeleteDictionaryFilterIndex() throws {
        var xml = try Xml(data: toyBoxByName)

        try xml.delete("characters", PathElement.filter(".*(z|Z).*"), "episodes", 0)

        XCTAssertEqual(xml.element["characters"]["Woody"]["episodes"].children.count, 3)
        XCTAssertEqual(xml.element["characters"]["Zurg"]["episodes"].children.count, 2)
        XCTAssertEqual(xml.element["characters"]["Buzz"]["episodes"].children.count, 2)
    }

    // MARK: - Delete if empty

    func testDeleteIfEmpty() throws {
        var xml = try Xml(data: toyBoxWithOneEpisode)
        let path = Path("characters", 0, "episodes", 0)

        try xml.delete(path, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try xml.get("characters", 0, "episodes"), .subscriptMissingKey(path: Path("toybox", "characters", 0), key: "episodes", bestMatch: nil))
    }
}
