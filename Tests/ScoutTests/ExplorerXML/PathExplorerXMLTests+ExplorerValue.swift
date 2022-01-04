//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML
@testable import Scout
import XCTest

final class ExplorerXMLExplorerValueTests: XCTestCase {

    func testString() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "toto"),
            expected: "toto")
    }

    func testString_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(name: "name", value: "toto").with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": "toto"
            ]
        )
    }

    func testString_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(name: "name", value: "toto").with(attributes: ["parent": "tata"]),
            expected: [
                "name": "toto", "parent": "tata"
            ]
        )
    }

    func testInt() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "20"),
            expected: 20)
    }

    func testInt_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "20").with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": 20
            ]
        )
    }

    func testInt_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(name: "user", value: "toto").with(attributes: ["score": "10"]),
            expected: [
                "user": "toto", "score": 10
            ]
        )
    }

    func testDouble() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "10.5"),
            expected: 10.5)
    }

    func testDouble_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "10.5").with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": 10.5
            ]
        )
    }

    func testDouble_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(name: "user", value: "toto").with(attributes: ["score": "10.5"]),
            expected: [
                "user": "toto", "score": 10.5
            ]
        )
    }

    func testBool() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "true"),
            expected: true)
    }

    func testBool_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(name: "", value: "true").with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": true
            ]
        )
    }

    func testBool_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(name: "user", value: "toto").with(attributes: ["isAdmin": "true"]),
            expected: [
                "user": "toto", "isAdmin": true
            ]
        )
    }

    // MARK: Group

    func testArray() {
        testExplorerValue(
            initial: ExplorerXML(value: ["Riri", "Fifi", "Loulou"]),
            expected: ["Riri", "Fifi", "Loulou"])
    }

    func testArray_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(value: ["Riri", "Fifi", "Loulou"]).with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": ["Riri", "Fifi", "Loulou"]
            ]
        )
    }

    func testArray_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(value: ["Riri", "Fifi", "Loulou"]).with(attributes: ["parent": "tata"]),
            expected: [
                "parent": "tata", "elements": ["Riri", "Fifi", "Loulou"]
            ]
        )
    }

    func testDictionary() {
        testExplorerValue(
            initial: ExplorerXML(value: ["Toto": [true], "Endo": 1]),
            expected: ["Toto": [true], "Endo": 1])
    }

    func testDictionary_SplitAttributes() {
        testExplorerValue(
            initial: ExplorerXML(value: ["Toto": [true], "Endo": 1]).with(attributes: ["parent": "tata"]),
            expected: [
                "attributes": ["parent": "tata"],
                "value": ["Toto": [true], "Endo": 1]
            ]
        )
    }

    func testDictionary_MergeAttributes() {
        testExplorerValue(
            attributesStrategy: .merge(duplicatesStrategy: .element),
            initial: ExplorerXML(value: ["Toto": [true], "Endo": 1]).with(attributes: ["parent": "tata"]),
            expected: [
                "parent": "tata", "Toto": [true], "Endo": 1
            ]
        )
    }
}

extension ExplorerXMLExplorerValueTests {

    func testExplorerValue(
        attributesStrategy: ExplorerXML.AttributesStrategy = .split,
        initial: ExplorerXML,
        expected: ExplorerValue,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(initial.explorerValue(attributesStrategy: attributesStrategy), expected)
    }
}
