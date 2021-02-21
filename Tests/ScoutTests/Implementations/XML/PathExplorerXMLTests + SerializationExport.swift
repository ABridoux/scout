//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

final class PathExplorerXMLSerializationExportTests: XCTestCase {

    // MARK: Single value

    func testExportString() throws {
        let element = AEXMLElement(name: "root")
        element.value = "Katana"

        let result = serialize(element: element)

        let string = try XCTUnwrap(result as? String)
        XCTAssertEqual(string, "Katana")
    }

    func testExportInt() throws {
        let element = AEXMLElement(name: "root")
        element.value = "10"

        let result = serialize(element: element)

        let int = try XCTUnwrap(result as? Int)
        XCTAssertEqual(int, 10)
    }

    func testExportDouble() throws {
        let element = AEXMLElement(name: "root")
        element.value = "10.5"

        let result = serialize(element: element)

        let double = try XCTUnwrap(result as? Double)
        XCTAssertEqual(double, 10.5)
    }

    func testExportBool() throws {
        let element = AEXMLElement(name: "root")
        element.value = "true"

        let result = serialize(element: element)

        let bool = try XCTUnwrap(result as? Bool)
        XCTAssertEqual(bool, true)
    }

    // MARK: Group value

    func testExportArray() throws {
        let element = AEXMLElement(name: "ducks")
        let ducks = ["Riri", "Fifi", "Loulou"]
        ducks.forEach { element.addChild(name: "duck", value: $0) }

        let result = serialize(element: element)

        let array = try XCTUnwrap(result as? [String])
        XCTAssertEqual(array, ducks)
    }

    func testExportDictionary() throws {
        let element = AEXMLElement(name: "ducks")
        let ducks = ["Riri": 20, "Fifi": 10, "Loulou": 30]
        ducks.forEach { element.addChild(name: $0.key, value: String($0.value)) }

        let result = serialize(element: element)

        let dict = try XCTUnwrap(result as? [String: Int])
        XCTAssertEqual(dict, ducks)
    }

    func testExportDictionarySameKey() throws {
        let element =  AEXMLElement(name: "ducks")
        let ducks: [(key: String, value: Int)] = [("Riri", 20), ("Fifi", 10), ("Loulou", 30), ("Loulou", 40), ("Fifi", 40), ("Loulou", 60)]
        ducks.forEach { element.addChild(name: $0.key, value: String($0.value)) }

        let result = serialize(element: element)

        let dict = try XCTUnwrap(result as? [String: Int])
        let expectedDict = ["Riri": 20, "Fifi": 10, "Loulou": 30, "Loulou-1": 40, "Fifi-1": 40, "Loulou-2": 60]
        XCTAssertEqual(dict, expectedDict)
    }

    func testExportArrayOfArrays() throws {
        let element = AEXMLElement(name: "animals")
        let ducks = ["Riri", "Fifi", "Loulou"]
        let ducksElement = AEXMLElement(name: "animals")
        ducks.forEach { ducksElement.addChild(name: "duck", value: $0) }
        let mouses = ["Mickey", "Minnie"]
        let mousesElement = AEXMLElement(name: "animals")
        mouses.forEach { mousesElement.addChild(name: "mouse", value: $0) }
        element.addChildren([ducksElement, mousesElement])

        let result = serialize(element: element)

        let array = try XCTUnwrap(result as? [[String]])
        XCTAssertEqual(array, [ducks, mouses])
    }

    func testExportArrayOfDictionaries() throws {
        let element = AEXMLElement(name: "animals")
        let ducks = ["Riri": 1, "Fifi": 2, "Loulou": 3]
        let ducksElement = AEXMLElement(name: "animals")
        ducks.forEach { ducksElement.addChild(name: $0.key, value: String($0.value)) }
        let mouses = ["Mickey": 4, "Minnie": 5]
        let mousesElement = AEXMLElement(name: "animals")
        mouses.forEach { mousesElement.addChild(name: $0.key, value: String($0.value)) }
        element.addChildren([ducksElement, mousesElement])

        let result = serialize(element: element)

        let array = try XCTUnwrap(result as? [[String: Int]])
        XCTAssertEqual(array, [ducks, mouses])
    }

    func testExportDictionaryOfDictonaries() throws {
        let element = AEXMLElement(name: "animals")
        let ducks = ["Riri": 1, "Fifi": 2, "Loulou": 3]
        let ducksElement = AEXMLElement(name: "ducks")
        ducks.forEach { ducksElement.addChild(name: $0.key, value: String($0.value)) }
        let mouses = ["Mickey": 4, "Minnie": 5]
        let mousesElement = AEXMLElement(name: "mouses")
        mouses.forEach { mousesElement.addChild(name: $0.key, value: String($0.value)) }
        element.addChildren([ducksElement, mousesElement])

        let result = serialize(element: element)

        let array = try XCTUnwrap(result as? [String: [String: Int]])
        XCTAssertEqual(array, ["ducks": ducks, "mouses": mouses])
    }

    func testExportDictionaryOfArrays() throws {
        let element = AEXMLElement(name: "animals")
        let ducks = ["Riri", "Fifi", "Loulou"]
        let ducksElement = AEXMLElement(name: "ducks")
        ducks.forEach { ducksElement.addChild(name: "duck", value: $0) }
        let mouses = ["Mickey", "Minnie"]
        let mousesElement = AEXMLElement(name: "mouses")
        mouses.forEach { mousesElement.addChild(name: "mouse", value: $0) }
        element.addChildren([ducksElement, mousesElement])

        let result = serialize(element: element)

        let array = try XCTUnwrap(result as? [String: [String]])
        XCTAssertEqual(array, ["ducks": ducks, "mouses": mouses])
    }

    // MARK: Tags

    func testExportTagSingleValue() throws {
        let element = AEXMLElement(name: "root")
        element.value = "Katana"
        element.attributes["name"] = "Shiburu"
        element.attributes["damage"] = String(30)

        let result = serialize(element: element)

        let dictResult = try XCTUnwrap(result as? [String: Any])
        let attributes = try XCTUnwrap(dictResult["attributes"] as? [String: Any])
        let value = try XCTUnwrap(dictResult["value"] as? String)
        XCTAssertEqual(attributes["name"] as? String, "Shiburu")
        XCTAssertEqual(attributes["damage"] as? Int, 30)
        XCTAssertEqual(value, "Katana")
    }

    func testExportTagDictionary() throws {
        let element = AEXMLElement(name: "ducks")
        let ducks = ["Riri": 20, "Fifi": 10, "Loulou": 30]
        ducks.forEach { element.addChild(name: $0.key, value: String($0.value)) }
        element.attributes["uncle"] = "Scrooge"
        element.attributes["age"] = String(70)

        let result = serialize(element: element)

        let dict = try XCTUnwrap(result as? [String: Any])
        let attributes = try XCTUnwrap(dict["attributes"] as? [String: Any])
        let value = try XCTUnwrap(dict["value"] as? [String: Int])
        XCTAssertEqual(attributes["uncle"] as? String, "Scrooge")
        XCTAssertEqual(attributes["age"] as? Int, 70)
        XCTAssertEqual(value, ducks)
    }

    func testExportTagArray() throws {
        let element = AEXMLElement(name: "ducks")
        let ducks = ["Riri", "Fifi", "Loulou"]
        ducks.forEach { element.addChild(name: "duck", value: $0) }
        element.attributes["uncle"] = "Scrooge"
        element.attributes["age"] = String(70)

        let result = serialize(element: element)

        let dict = try XCTUnwrap(result as? [String: Any])
        let attributes = try XCTUnwrap(dict["attributes"] as? [String: Any])
        let value = try XCTUnwrap(dict["value"] as? [String])
        XCTAssertEqual(attributes["uncle"] as? String, "Scrooge")
        XCTAssertEqual(attributes["age"] as? Int, 70)
        XCTAssertEqual(value, ducks)
    }
}

extension PathExplorerXMLSerializationExportTests {

    func serialize(element: AEXMLElement) -> Any {
        let explorer = PathExplorerXML(element: element, path: .empty)
        return explorer.serialize(element: element)
    }
}
