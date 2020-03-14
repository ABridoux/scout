//
//  File.swift
//  
//
//  Created by Alexis Bridoux on 14/03/2020.
//

import XCTest
import AEXML
@testable import PathExplorer

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
        XCTAssertNoThrow(try PathExplorerXML(data: stubData1))
    }

    func testSubscriptString() throws {
        let xml = try PathExplorerXML(data: stubData1)

        XCTAssertEqual(xml["stringValue"].string, "Hello")
        XCTAssertEqual(xml["boolValue"].bool, false)
    }

    func testSubscriptStringSet() throws {
        var xml = try PathExplorerXML(data: stubData1)

        xml["stringValue"] = PathExplorerXML(value: "world")

        XCTAssertEqual(xml["stringValue"].string, "world")
        XCTAssertEqual(xml["boolValue"].bool, false)
    }

    func testSubscriptInt() throws {
        let xml = try PathExplorerXML(data: stubData2)

        XCTAssertEqual(xml["dogs"][1].string, "Spot")
    }

    func testSubscriptIntSet() throws {
        var xml = try PathExplorerXML(data: stubData2)

        xml["dogs"][1] = PathExplorerXML(value: "Endo")
        XCTAssertEqual(xml["dogs"][1].string, "Endo")
    }

    func testSubscriptVariadic() throws {
        let xml = try PathExplorerXML(data: stubData2)

        XCTAssertEqual(xml["dogs", 1].string, "Spot")
    }

    func testSubscriptVariadicSet() throws {
        var xml = try PathExplorerXML(data: stubData2)

        xml["dogs", 1] = "Endo"

        XCTAssertEqual(xml["dogs", 1].string, "Endo")
    }

    func testSubscriptArray() throws {
        let xml = try PathExplorerXML(data: stubData2)

        let path: [PathElement] = ["dogs", 1]

        XCTAssertEqual(xml[path].string, "Spot")
    }

    func testSubscriptArraySet() throws {
        var xml = try PathExplorerXML(data: stubData2)
        let path: [PathElement] = ["dogs", 1]

        xml[path] = "Endo"

        XCTAssertEqual(xml[path].string, "Endo")
    }
}
