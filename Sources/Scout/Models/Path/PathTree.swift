//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// A collection of paths arranged following their common prefixes.
///
/// Useful when building a PathExplorer from a list of paths to reuse the last created explorer
/// to add children to it (rather than starting again from the root each time).
final class PathTree<Value: Equatable> {

    // MARK: - Properties

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

    // MARK: - Initialisation

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
}

// MARK: - Subscript

extension PathTree {

    subscript(_ element: PathElement) -> PathTree? {
        switch value {
        case .uninitializedLeaf, .leaf: return nil
        case .node(let children): return children.first { $0.element == element }
        }
    }

    subscript(path: Path) -> PathTree? {
        var currentTree = self
        for element in path {
            if let tree = currentTree[element] {
                currentTree = tree
            } else {
                return nil
            }
        }
        return currentTree
    }
}

// MARK: - Children

extension PathTree {

    /// Add a node to the tree.
    /// - note: If the tree is a leaf, it will be transformed into a node with children
    func addChild(_ child: PathTree) {
        switch value {
        case .uninitializedLeaf: break
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

extension PathTree: Equatable {
    static func == (lhs: PathTree<Value>, rhs: PathTree<Value>) -> Bool {
        lhs.element == rhs.element && lhs.value == rhs.value
    }
}

// MARK: - Equatable

extension PathTree {

    enum ValueType: Equatable {
        case uninitializedLeaf
        case leaf(value: Value)
        case node(children: [PathTree])
    }
}

// MARK: - Paths insertion

extension PathTree {

    /// Insert the path in the tree, returning the leaf that holds the last path's elements
    func insert(path: Path) -> PathTree {
        insert(path: Slice(path))
    }

    /// Insert the path in the tree, returning the leaf that holds the last path's elements
    func insert(path: Slice<Path>) -> PathTree {
        guard let (head, tail) = path.headAndTail() else { return self }
        let insertedChild: PathTree

        switch value {

        case .uninitializedLeaf, .leaf:
            let child = PathTree(value: .uninitializedLeaf, element: head)
            insertedChild = child.insert(path: tail)
            value = .node(children: [child])

        case .node(var children):
            if let existing = children.first(where: { $0.element == head }) {
                insertedChild = existing.insert(path: tail)
            } else {
                let child = PathTree(value: .uninitializedLeaf, element: head)
                insertedChild = child.insert(path: tail)
                children.append(child)
            }

            value = .node(children: children)
        }

        return insertedChild
    }
}

// MARK: - PathExplorer

extension ExplorerXML {

    static func newValue(exploring tree: PathTree<String?>) throws -> ExplorerXML {
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

        case .uninitializedLeaf: throw ExplorerError(description: "Uninitialized leaf encountered while building from PathTree")
        }

        return explorer
    }
}

extension ExplorerValue {

    static func newValue(exploring tree: PathTree<ExplorerValue?>) throws -> ExplorerValue? {
        switch tree.value {
        case .leaf(let value):
            return value

        case .node(let children):
            if let mappedChildren = children.unwrapAll(\.keyed) {
                let dict = try mappedChildren.compactMap { (key, tree) -> (String, ExplorerValue)? in
                    if let value = try newValue(exploring: tree) {
                        return (key, value)
                    }
                    return nil
                }
                return dictionary <^> Dictionary(uniqueKeysWithValues: dict)

            } else if let mappedChildren = children.unwrapAll(\.indexed) {
                return try array <^> mappedChildren.compactMap { try newValue(exploring: $0.tree) }
            } else {
                throw ExplorerError(description: "Invalid children values to build value from PathTree. Expected only keys or only indexes PathElements")
            }

        case .uninitializedLeaf: throw ExplorerError(description: "Uninitialized leaf encountered while building from PathTree")
        }
    }
}
