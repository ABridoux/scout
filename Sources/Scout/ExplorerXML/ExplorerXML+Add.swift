//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Add

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        if referenceIsShared() { self = copy() }
        try _add(value: .explorerValue(value), at: Slice(path))
    }

    /// Add the given `AEXMLElement` value rather than an `ExplorerValue`
    public mutating func add(_ element: Element, at path: Path) throws {
        if referenceIsShared() { self = copy() }
        try _add(value: .explorerXML(ExplorerXML(element: element)), at: Slice(path))
    }

    /// Add the given `ExplorerXML` value rather than an `ExplorerValue`
    public mutating func add(_ explorer: ExplorerXML, at path: Path) throws {
        if referenceIsShared() { self = copy() }
        try _add(value: .explorerXML(explorer), at: Slice(path))
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> ExplorerXML {
        var copy = self.copy()
        try copy.add(value, at: path)
        return copy
    }

    /// Add the given `AEXMLElement` value rather than an `ExplorerValue`
    public func adding(_ element: Element, at path: Path) throws -> ExplorerXML {
        var copy = self.copy()
        try copy.add(element, at: path)
        return copy
    }

    /// Add the given `ExplorerXML` value rather than an `ExplorerValue`
    public func adding(_ explorerXML: ExplorerXML, at path: Path) throws -> ExplorerXML {
        var copy = self.copy()
        try copy.add(explorerXML, at: path)
        return copy
    }

    // MARK: General function

    /// Return the value if it should be added to the parent
    private func _add(value: ValueSetter, at path: SlicePath) throws {
        guard let (head, tail) = path.headAndTail() else {
            set(value: value)
            return
        }

        return try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): try add(value: value, for: key, tail: tail)
            case .index(let index): try add(value: value, at: index, tail: tail)
            case .count: try addCount(value: value, tail: tail)
            default: throw ExplorerError.wrongUsage(of: head)
            }
        }
    }

    // MARK: PathElement

    private func add(value: ValueSetter, for key: String, tail: SlicePath) throws {
        if let next = try? getJaroWinkler(key: key) {
            try next._add(value: value, at: tail)
        } else {
            let newExplorer = ExplorerXML(name: key)
            addChild(newExplorer)
            try newExplorer._add(value: value, at: tail)
        }
    }

    private func add(value: ValueSetter, at index: Int, tail: SlicePath) throws {
        if index == childrenCount {
            return try addCount(value: value, tail: tail)
        }

        let index = try Self.computeIndex(from: index, arrayCount: childrenCount)

        guard tail.isEmpty else {
            try children[index]._add(value: value, at: tail)
            return
        }

        let childToInsert = ExplorerXML(name: childrenName)
        try childToInsert._add(value: value, at: tail)
        var newChildren = children
        newChildren.insert(childToInsert, at: index)
        removeChildrenFromParent()
        newChildren.forEach(addChild)
    }

    private func addCount(value: ValueSetter, tail: SlicePath) throws {
        let newChild = ExplorerXML(name: childrenName)
        addChild(newChild)
        try newChild._add(value: value, at: tail)
    }
}
