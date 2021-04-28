//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML
@testable import Scout
import XCTest

final class ExplorerXMLCOWTests: XCTestCase {

    func testSet() throws {
        let explorer = ExplorerXML(value: ["Endo": true, "Toto": 20])
        var copy = explorer

        try copy.set("Endo", to: false)

        XCTAssertEqual(explorer.explorerValue(), ["Endo": true, "Toto": 20])
        XCTAssertEqual(copy.explorerValue(), ["Endo": false, "Toto": 20])
    }

    func testDelete() throws {
        let explorer = ExplorerXML(value: ["Endo": true, "Toto": 20])
        var copy = explorer

        try copy.delete("Toto")

        XCTAssertEqual(explorer.explorerValue(), ["Endo": true, "Toto": 20])
        try XCTAssertEqual(copy.dictionary(of: Bool.self), ["Endo": true])
    }

    func testAdd() throws {
        let explorer = ExplorerXML(value: ["Endo": true, "Toto": 20])
        var copy = explorer

        try copy.add("Riri", at: "duck")

        XCTAssertEqual(explorer.explorerValue(), ["Endo": true, "Toto": 20])
        XCTAssertEqual(copy.explorerValue(), ["Endo": true, "Toto": 20, "duck": "Riri"])
    }
}
