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

    func testDeleteIfEmpty() throws {
        var xml = try Xml(data: toyBoxWithOneEpisode)
        let path = Path("characters", 0, "episodes", 0)

        try xml.delete(path, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try xml.get("characters", 0, "episodes"), .subscriptMissingKey(path: Path("toybox", "characters", 0), key: "episodes", bestMatch: nil))
    }
}
