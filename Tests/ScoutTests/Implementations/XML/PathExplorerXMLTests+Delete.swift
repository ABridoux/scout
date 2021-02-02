//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

extension PathExplorerXMLTests {

    func testDeleteIndex() throws {
        var xml = try Xml(data: stubData2)

        try xml.delete(["dogs", 1])

        XCTAssertEqual(try xml.get("dogs", 1).string, "Betty")
        XCTAssertThrowsError(try xml.get("dogs", 2))
    }

    func testDeleteLastNegativeIndex() throws {
        var xml = try Xml(data: stubData2)

        try xml.delete(["dogs", -1])

        XCTAssertEqual(try xml.get("dogs", 1).string, "Spot")
        XCTAssertEqual(xml.element.children[0].children.count, 2)
    }

    func testDeleteNegativeIndex() throws {
        var xml = try Xml(data: stubData2)

        try xml.delete(["dogs", -2])

        XCTAssertEqual(try xml.get("dogs", 1).string, "Betty")
        XCTAssertEqual(xml.element.children[0].children.count, 2)
    }

    func testDeleteKey() throws {
        var xml = try Xml(data: toyBoxByName)

        try xml.delete(["characters", "Woody"])

        XCTAssertThrowsError(try xml.get("characters", "Woody"))
        XCTAssertEqual(xml.element.children[0].children.count, 2)
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

    // MARK: - Regular expression pattern

    func testDeleteKeyPattern() throws {
        let newInfos = { () -> AEXMLElement in
            let element = AEXMLElement(name: "informations")
            element.addChild(name: "score", value: "20")
            element.addChild(name: "game", value: "Dark Souls")
            return element
        }
        let root = AEXMLElement(name: "root")
        root.addChild(newInfos())
        let firstPlayer = AEXMLElement(name: "Cathyna")
        firstPlayer.addChild(newInfos())
        firstPlayer.addChild(name: "score", value: "10")
        let secondPlayer = AEXMLElement(name: "Octopus")
        secondPlayer.addChild(newInfos())
        secondPlayer.addChild(name: "score", value: "5")
        root.addChildren([firstPlayer, secondPlayer])
        var explorer = PathExplorerXML(element: root, path: .empty)
        let regex = try NSRegularExpression(pattern: "informations")

        try explorer.delete(regularExpression: regex, deleteIfEmpty: false)

        XCTAssertErrorsEqual(try explorer.get("informations"), .subscriptMissingKey(path: .empty, key: "informations", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("Cathyna", "informations"), .subscriptMissingKey(path: Path("Cathyna"), key: "informations", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("Octopus", "informations"), .subscriptMissingKey(path: Path("Octopus"), key: "informations", bestMatch: nil))
    }

    func testDeleteKeyPatternSingleValueDeleteIfEmpty() throws {
        let root = AEXMLElement(name: "root")
        let firstMovie = AEXMLElement(name: "movie")
        firstMovie.addChild(name: "title", value: "Worst day to die")
        firstMovie.addChild(name: "rate", value: "3.5")
        let secondMovie = AEXMLElement(name: "movie")
        secondMovie.addChild(name: "title", value: "Don't get rick'rolled!")
        let movies = AEXMLElement(name: "movies")
        movies.addChildren([firstMovie, secondMovie])
        root.addChild(movies)
        var explorer = PathExplorerXML(element: root, path: .empty)
        let regex = try NSRegularExpression(pattern: "title")

        try explorer.delete(regularExpression: regex, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try explorer.get("movies", 1), .subscriptWrongIndex(path: Path("movies"), index: 1, arrayCount: 1))
        XCTAssertEqual(try explorer.get("movies", 0, "rate").double, 3.5)
    }

    func testDeleteKeyPatternDeleteIfEmpty() throws {
        let newInfos = { () -> AEXMLElement in
            let element = AEXMLElement(name: "informations")
            element.addChild(name: "score", value: "20")
            element.addChild(name: "game", value: "Dark Souls")
            return element
        }
        let root = AEXMLElement(name: "root")
        root.addChild(newInfos())
        let firstPlayer = AEXMLElement(name: "Cahtyna")
        firstPlayer.addChild(newInfos())
        let secondPlayer = AEXMLElement(name: "Octopus")
        secondPlayer.addChild(newInfos())
        root.addChildren([firstPlayer, secondPlayer])
        var explorer = PathExplorerXML(element: root, path: .empty)
        let regex = try NSRegularExpression(pattern: "informations")

        try explorer.delete(regularExpression: regex, deleteIfEmpty: true)

        XCTAssertErrorsEqual(try explorer.get("informations"), .subscriptMissingKey(path: .empty, key: "informations", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("Cathyna"), .subscriptMissingKey(path: .empty, key: "Cathyna", bestMatch: nil))
        XCTAssertErrorsEqual(try explorer.get("Octopus"), .subscriptMissingKey(path: .empty, key: "Octopus", bestMatch: nil))
    }
}
