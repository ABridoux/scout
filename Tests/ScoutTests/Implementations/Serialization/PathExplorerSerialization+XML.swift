//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

final class PathExplorerSerializationXMLTests: XCTestCase {

    func testExportString() throws {
        let root = xmlRoot(with: "Ducks")

        XCTAssertEqual(root.string, "Ducks")
    }

    func testExportInt() throws {
        let root = xmlRoot(with: "Ducks")

        XCTAssertEqual(root.string, "Ducks")
    }

    func testExportDouble() throws {
        let root = xmlRoot(with: 10.5)

        XCTAssertEqual(root.double, 10.5)
    }

    func testExportBool() throws {
        let root = xmlRoot(with: false)

        XCTAssertEqual(root.bool, false)
    }

    func testExportDictionary1Level() throws {
        let root = xmlRoot(with: ["Riri": 0, "Fifi": 20, "Loulou": 30])

        XCTAssertEqual(root.firstDescendant { $0.name == "Riri" }?.int, 0)
        XCTAssertEqual(root.firstDescendant { $0.name == "Fifi" }?.int, 20)
        XCTAssertEqual(root.firstDescendant { $0.name == "Loulou" }?.int, 30)
    }

    func testExportArray1Level() throws {
       let root = xmlRoot(with: ["Riri", "Fifi", "Loulou"])

        XCTAssertEqual(root.children[0].string, "Riri")
        XCTAssertEqual(root.children[1].string, "Fifi")
        XCTAssertEqual(root.children[2].string, "Loulou")
    }

    func testExportDictionaryOfDictionaries() throws {
        let ducks = ["Riri": 10, "Fifi": 20, "Loulou": 30]
        let dict: [String: Any] = ["ducks": ducks]

        let root = xmlRoot(with: dict)
        let ducksAndScoresTuples = try XCTUnwrap(root.firstDescendant { $0.name == "ducks" }?.children.map { ($0.name, $0.int) })
        let ducksAndScores = Dictionary(uniqueKeysWithValues: ducksAndScoresTuples)

        XCTAssertEqual(ducksAndScores["Riri"], 10)
        XCTAssertEqual(ducksAndScores["Fifi"], 20)
        XCTAssertEqual(ducksAndScores["Loulou"], 30)
    }

    func testExportArrayOfArrays() throws {
        let mouses = ["Mickey", "Minnie"]
        let ducks = ["Riri", "Fifi", "Loulou"]
        let dict: [Any] = [mouses, ducks]

        let root = xmlRoot(with: dict)
        let mousesResult = try XCTUnwrap(root.children[0].children.map(\.string))
        let ducksResult = try XCTUnwrap(root.children[1].children.map(\.string))

        XCTAssertEqual(Set(mousesResult), Set(mouses))
        XCTAssertEqual(Set(ducksResult), Set(ducks))
    }

    func testExportDictionaryOfArrays() throws {
        let mouses = ["Mickey", "Minnie"]
        let ducks = ["Riri", "Fifi", "Loulou"]
        let dict: [String: Any] = ["mouses": mouses, "ducks": ducks]

        let root = xmlRoot(with: dict)
        let mousesResult = try XCTUnwrap(root.firstDescendant { $0.name == "mouses" }?.children.map(\.string))
        let ducksResult = try XCTUnwrap(root.firstDescendant { $0.name == "ducks" }?.children.map(\.string))

        XCTAssertEqual(Set(mousesResult), Set(mouses))
        XCTAssertEqual(Set(ducksResult), Set(ducks))
    }

    func testExportArrayOfDictionaries() throws {
        let ducks = ["Riri": 10, "Fifi": 20, "Loulou": 30]
        let mouses = ["Mickey": true, "Minnie": false]
        let dict: [Any] = [ducks, mouses]

        let root = xmlRoot(with: dict)
        let ducksScoresTuples = try XCTUnwrap(root.children[0].children.map { ($0.name, $0.int) })
        let mousesFlagTuples = try XCTUnwrap(root.children[1].children.map { ($0.name, $0.bool) })
        let ducksAndScores = Dictionary(uniqueKeysWithValues: ducksScoresTuples)
        let mousesAndFlags = Dictionary(uniqueKeysWithValues: mousesFlagTuples)


        XCTAssertEqual(ducksAndScores["Riri"], 10)
        XCTAssertEqual(ducksAndScores["Fifi"], 20)
        XCTAssertEqual(ducksAndScores["Loulou"], 30)
        XCTAssertEqual(mousesAndFlags["Mickey"], true)
        XCTAssertEqual(mousesAndFlags["Minnie"], false)
    }
}

extension PathExplorerSerializationXMLTests {

    func xmlRoot(with value: Any) -> AEXMLElement {
        let explorer = Json(value: value)

        let data = try explorer.exportToXML() !! "Export to XML failed"

        do {
            return try AEXMLDocument(xml: data).root
        } catch {
            preconditionFailure(error.localizedDescription)
        }
    }
}
