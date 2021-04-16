//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        try _add(value: .explorerValue(value), at: Slice(path))
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> ExplorerXML {
        var copy = self.copy()
        try copy.add(value, at: path)
        return copy
    }

    // MARK: General function

    /// Return the value if it should be added to the parent
    private func _add(value: ValueSetter, at path: SlicePath) throws {
        guard let element = path.first else {
            set(value: value)
            return
        }

        let remainder = path.dropFirst()

        return try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key): try add(value: value, for: key, remainder: remainder)
            case .index(let index): try add(value: value, at: index, remainder: remainder)
            case .count: try addCount(value: value, remainder: remainder)
            default: throw ExplorerError.wrongUsage(of: element)
            }
        }
    }

    // MARK: PathElement

    private func add(value: ValueSetter, for key: String, remainder: SlicePath) throws {
        if let next = try? getJaroWinkler(key: key) {
            try next._add(value: value, at: remainder)
        } else {
            let newExplorer = ExplorerXML(name: key)
            addChild(newExplorer)
            try newExplorer._add(value: value, at: remainder)
        }
    }

    private func add(value: ValueSetter, at index: Int, remainder: SlicePath) throws {
        let index = try computeIndex(from: index, arrayCount: childrenCount)

        if remainder.isEmpty {
            let childToInsert = ExplorerXML(name: childrenName)
            childToInsert.set(value: value)
            var newChildren = children
            newChildren.insert(childToInsert, at: index)
            removeChildrenFromParent()
            newChildren.forEach(addChild)
        } else {
            try children[index]._add(value: value, at: remainder)
        }
    }

    private func addCount(value: ValueSetter, remainder: SlicePath) throws {
        let newChild = ExplorerXML(name: childrenName)
        addChild(newChild)
        try newChild._add(value: value, at: remainder)
    }
}
