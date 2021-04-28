//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

@testable import Scout
import XCTest

final class PathTreeTests: XCTestCase {

    // MARK: - Paths array

    func testInsertPath() {
        typealias Tree = PathTree<String>

        let path = Path(elements: "Tom", "name", "first")
        let root = Tree.root()
        let first = root.insert(path: Slice(path))

        XCTAssertNotNil(root["Tom"]?["name"]?["first"])
        XCTAssertEqual(first.value, .uninitializedLeaf)
        XCTAssertEqual(first.element, "first")
    }

    func testInsertTwoPaths_2ElementsCommonPrefix() {
        typealias Tree = PathTree<String>

        let path1 = Path(elements: "Tom", "name", "first")
        let path2 = Path(elements: "Tom", "name", "last")
        let root = Tree.root()
        let first = root.insert(path: Slice(path1))
        let last = root.insert(path: Slice(path2))

        XCTAssertNotNil(root["Tom"]?["name"]?["first"])
        XCTAssertNotNil(root["Tom"]?["name"]?["last"])
        XCTAssertEqual(first.element, "first")
        XCTAssertEqual(last.element, "last")
        XCTAssertEqual(last.value, .uninitializedLeaf)
    }

    func testInsertTwoPaths_1ElementCommonPrefix() {
        typealias Tree = PathTree<String>

        let path1 = Path(elements: "Tom", "name", "first")
        let path2 = Path(elements: "Tom", "score")
        let root = Tree.root()
        let first = root.insert(path: Slice(path1))
        let score = root.insert(path: Slice(path2))

        XCTAssertNotNil(root["Tom"]?["name"]?["first"])
        XCTAssertNotNil(root["Tom"]?["score"])
        XCTAssertEqual(first.element, "first")
        XCTAssertEqual(score.element, "score")
        XCTAssertEqual(score.value, .uninitializedLeaf)
    }

    func testBuildFromPathsSet() {
        typealias Tree = PathTree<String>
        let paths: [Path] = [Path("Tom", "hobbies", 0), Path("Tom", "hobbies", 1), Path("Tom", "name", "first"), Path("Tom", "name", "last")]
        let root = Tree.root()

        let trees = paths.map(root.insert)

        XCTAssertNotNil(root[paths[0]])
        XCTAssertNotNil(root[paths[1]])
        XCTAssertNotNil(root[paths[2]])
        XCTAssertNotNil(root[paths[3]])
        XCTAssertEqual(trees[0].element, 0)
        XCTAssertEqual(trees[1].element, 1)
        XCTAssertEqual(trees[2].element, "first")
        XCTAssertEqual(trees[3].element, "last")

    }

    // MARK: - PathExplorer

    func testExplorerValueFromTree() throws {
        typealias Tree = PathTree<ExplorerValue?>
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
        typealias Tree = PathTree<String?>
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
