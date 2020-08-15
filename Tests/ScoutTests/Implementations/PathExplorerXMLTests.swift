//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

final class PathExplorerXMLTests: XCTestCase {

    let stubData1: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "root")
        root.addChild(.init(name: "stringValue", value: "Hello", attributes: [:]))
        root.addChild(.init(name: "boolValue", value: "false", attributes: [:]))
        document.addChild(root)

        return document.xml.data(using: .utf8)!
    }()

    let stubData2: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "root")
        let dogs = AEXMLElement(name: "dogs")
        dogs.addChildren([.init(name: "dog", value: "Villy", attributes: [:]),
                          .init(name: "dog", value: "Spot", attributes: [:]),
                          .init(name: "dog", value: "Betty", attributes: [:])
                        ])
        root.addChild(dogs)
        document.addChild(root)

        return document.xml.data(using: .utf8)!
    }()

    // MARK: - Functions

    func testInitNotThrows() {
        XCTAssertNoThrow(try Xml(data: stubData1))
    }

    // MARK: Get

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

    func testGetArraySlice() throws {
        var xml = try Xml(data: stubData2)

        let path = Path(pathElements: .key("dogs"), .slice(.init(lower: 0, upper: 1)))
        xml = try xml.get(path)

        let resultValue = xml.element.children.map { $0.string }

        XCTAssertEqual(["Villy", "Spot"], resultValue)
    }

    // MARK: Set

    func testSubscriptStringSet() throws {
        var xml = try Xml(data: stubData1)

        try xml.set(key: "stringValue", to: "world")

        XCTAssertEqual(try xml.get(for: "stringValue").string, "world")
        XCTAssertEqual(try xml.get(for: "boolValue").bool, false)
    }

    func testSubscriptIntSet() throws {
        var xml = try Xml(data: stubData2)

        try xml.set("dogs", 1, to: "Endo")
        XCTAssertEqual(try xml.get(for: "dogs").get(at: 1).string, "Endo")
    }

    func testSubscriptArraySet() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("dogs", 1)

        try xml.set(path, to: "Endo")

        XCTAssertEqual(try xml.get(path).string, "Endo")
    }

    func testSetKeyName() throws {
        var xml = try Xml(data: stubData1)

        try xml.set(["stringValue"], keyNameTo: "kiki")

        XCTAssertEqual(try xml.get(for: "kiki").string, "Hello")
    }

    // MARK: Delete

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

    // MARK: Add

    func testAddKeyDict() throws {
        var xml = try Xml(data: stubData1)

        try xml.add("2", for: "intValue")

        XCTAssertEqual(try xml.get(for: "intValue").int, 2)
    }

    func testAddKeyArray() throws {
        var xml = try Xml(data: stubData2).get(for: "dogs")

        try xml.add("Endo", for: -1)

        XCTAssertEqual(try xml.get(at: 3).string, "Endo")
    }

    func testAddKeyArrayInsert() throws {
        var xml = try Xml(data: stubData2).get(for: "dogs")

        try xml.add("Endo", for: 1)

        XCTAssertEqual(try xml.get(at: 0).string, "Villy")
        XCTAssertEqual(try xml.get(at: 1).string, "Endo")
        XCTAssertEqual(try xml.get(at: 2).string, "Spot")
        XCTAssertEqual(try xml.get(at: 3).string, "Betty")
    }

    func testAddKey1() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("dogs", -1)

        try xml.add("Endo", at: path)

        XCTAssertEqual(try xml.get(["dogs", 3]).string, "Endo")
    }

    func testAddKey2() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("cats", -1)

        try xml.add("Mocka", at: path)

        XCTAssertEqual(try xml.get(["cats", 0]).string, "Mocka")
    }

    func testAddKey3() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("cats", "my_cat")

        try xml.add("Mocka", at: path)

        XCTAssertEqual(try xml.get(["cats", "my_cat"]).string, "Mocka")
    }

    // MARK: Array count

    func testGetCount() throws {
        let xml = try Xml(data: stubData2)

        XCTAssertEqual(try xml.get(for: "dogs").get(element: .count).int, 3)
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

    func testAddCount_ThrowsError() throws {
        var xml = try Xml(data: stubData2)
        let path = Path("root", "dogs", PathElement.count)

        XCTAssertErrorsEqual(try xml.add("Woomy", at: path), .wrongUsage(of: .count, in: path))
    }
}
