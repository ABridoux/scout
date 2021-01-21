//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

final class AEXMLExtensionsTests: XCTestCase {

    func testBestChildrenGroupDictionary() {
        let root = AEXMLElement(name: "root")

        let firstChild = AEXMLElement(name: "firstChild")
        firstChild.addChild(name: "animal", value: "snake")
        firstChild.addChild(name: "speed", value: "3")
        firstChild.addChild(name: "strength", value: "4")
        root.addChild(firstChild)

        let secondChild = AEXMLElement(name: "secondChild")
        secondChild.addChild(name: "animal", value: "bear")
        secondChild.addChild(name: "strength", value: "8")
        root.addChild(secondChild)

        XCTAssertEqual(root.bestChildrenGroupFit, .dictionary)
    }

    func testBestChildrenGroupArray() {
        let root = AEXMLElement(name: "root")

        let firstChild = AEXMLElement(name: "firstChild")
        firstChild.addChild(name: "animal", value: "snake")
        firstChild.addChild(name: "animal", value: "crocodile")
        root.addChild(firstChild)

        let secondChild = AEXMLElement(name: "secondChild")
        secondChild.addChild(name: "animal", value: "bear")
        secondChild.addChild(name: "animal", value: "panda")
        root.addChild(secondChild)

        XCTAssertEqual(root.bestChildrenGroupFit, .array)
    }
}
