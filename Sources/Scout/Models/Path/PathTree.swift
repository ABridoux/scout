//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

final class PathTree<Value> {

    let element: PathElement
    var value: ValueType

    var keyed: (key: String, tree: PathTree)? {
        if let key = element.key {
            return (key, self)
        }
        return nil
    }

    var indexed: (index: Int, tree: PathTree)? {
        if let index = element.index {
            return (index, self)
        }
        return nil
    }

    init(value: ValueType, element: PathElement) {
        self.value = value
        self.element = element
    }

    static func leaf(value: Value, element: PathElement) -> PathTree {
        PathTree(value: .leaf(value: value), element: element)
    }

    static func node(children: [PathTree], element: PathElement) -> PathTree {
        PathTree(value: .node(children: children), element: element)
    }

    static func root() -> PathTree {
        .node(children: [], element: .key("root"))
    }

    /// Add a node to the tree.
    /// - note: If the tree is a leaf, it will be transformed into a node with children
    func addChild(_ child: PathTree) {
        switch value {
        case .leaf: value = .node(children: [child])
        case .node(var children):
            children.append(child)
            value = .node(children: children)
        }
    }

    func addLeaf(value: Value, element: PathElement) {
        let leaf = Self.leaf(value: value, element: element)
        addChild(leaf)
    }
}

extension PathTree {

    enum ValueType {
        case leaf(value: Value)
        case node(children: [PathTree])
    }
}

extension ExplorerXML {

    static func newValue(exploring tree: PathTree<String>) throws -> ExplorerXML {
        let name: String
        switch tree.element {
        case .key(let key): name = key
        case .index: name = Element.defaultName
        default: throw ExplorerError.wrongUsage(of: tree.element)
        }

        let explorer = ExplorerXML(name: name)

        switch tree.value {
        case .leaf(let value):
            explorer.set(value: value)
        case .node(let children):
            try children.forEach { childTree in
                let childExplorer = try ExplorerXML.newValue(exploring: childTree)
                explorer.addChild(childExplorer)
            }
        }

        return explorer
    }
}

extension ExplorerValue {

    static func newValue(exploring tree: PathTree<ExplorerValue>) throws -> ExplorerValue {
        switch tree.value {
        case .leaf(let value):
            return value

        case .node(let children):
            if let mappedChildren = children.unwrapAll(\.keyed) {
                let dict = try mappedChildren.map { try ($0.key, newValue(exploring: $0.tree)) }
                return dictionary <^> Dictionary(uniqueKeysWithValues: dict)
            } else if let mappedChildren = children.unwrapAll(\.indexed) {
                return try array <^> mappedChildren.map { try newValue(exploring: $0.tree) }
            } else {
                throw ExplorerError(description: "Invalid children values to build value from PathTree. Expected only keys or only indexes PathElements")
            }
        }
    }
}
