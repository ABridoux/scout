//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathTreeTests: XCTestCase {

    func testExplorerValueFromTree() throws {
        typealias Tree = PathTree<ExplorerValue>
        let root = Tree.root()
        let tom = Tree.node(children: [], element: "Tom")
        root.addChild(tom)
        tom.addLeaf(value: 30, element: "score")
        let hobbies = Tree.node(children: [], element: "hobbies")
        hobbies.addLeaf(value: "surfing", element: 0)
        hobbies.addLeaf(value: "cooking", element: 1)
        tom.addChild(hobbies)

        let value = try ExplorerValue.newValue(exploring: root)

        let expected: ExplorerValue = ["Tom": [ "score": 30, "hobbies": ["surfing", "cooking"]]]
        XCTAssertEqual(value, expected)
    }

    func testExplorerXMLFromTree() throws {
        typealias Tree = PathTree<String>
        let root = Tree.root()
        let tom = Tree.node(children: [], element: "Tom")
        root.addChild(tom)
        tom.addLeaf(value: "30", element: "score")
        let hobbies = Tree.node(children: [], element: "hobbies")
        hobbies.addLeaf(value: "surfing", element: 0)
        hobbies.addLeaf(value: "cooking", element: 1)
        tom.addChild(hobbies)

        let explorer = try ExplorerXML.newValue(exploring: root)

        let expected: ExplorerValue = ["Tom": [ "score": 30, "hobbies": ["surfing", "cooking"]]]
        XCTAssertEqual(explorer.explorerValue(), expected)
    }
}
