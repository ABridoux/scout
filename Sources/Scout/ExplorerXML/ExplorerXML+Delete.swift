//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        if referenceIsShared() { self = copy() }
        _ = try _delete(path: Slice(path), deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> ExplorerXML {
        var modified = copy()
        try modified.delete(path, deleteIfEmpty: deleteIfEmpty)
        return modified
    }

    // MARK: General function

    /// Returns `true` if the element should be deleted
    private func _delete(path: SlicePath, deleteIfEmpty: Bool) throws -> Bool {
        guard let (head, tail) = path.headAndTail() else { return true }

        try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): try delete(key: key, deleteIfEmpty: deleteIfEmpty, tail: tail)
            case .index(let index): try delete(index: index, deleteIfEmpty: deleteIfEmpty, tail: tail)
            case .filter(let pattern): try deleteFilter(with: pattern, deleteIfEmpty: deleteIfEmpty, tail: tail)
            case .slice(let bounds): try deleteSlice(within: bounds, deleteIfEmpty: deleteIfEmpty, tail: tail)
            case .count, .keysList:
                throw ExplorerError.wrongUsage(of: head)
            }
        }

        return false
    }

    // MARK: PathElement

    private func delete(key: String, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let next = try getJaroWinkler(key: key)
        try delete(tail: tail, on: next, deleteIfEmpty: deleteIfEmpty)
    }

    private func delete(index: Int, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let index = try computeIndex(from: index, arrayCount: childrenCount)
        let next = children[index]
        try delete(tail: tail, on: next, deleteIfEmpty: deleteIfEmpty)
    }

    private func deleteFilter(with pattern: String, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let regex = try NSRegularExpression(with: pattern)
        try children
            .filter { regex.validate($0.name) }
            .forEach { try delete(tail: tail, on: $0, deleteIfEmpty: deleteIfEmpty) }
    }

    private func deleteSlice(within bounds: Bounds, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let range = try bounds.range(arrayCount: childrenCount)
        try children[range].forEach { try delete(tail: tail, on: $0, deleteIfEmpty: deleteIfEmpty) }
    }
}

extension ExplorerXML {

    /// Delete the tail in the child and then remove it from its parent if necessary
    private func delete(tail: SlicePath, on child: ExplorerXML, deleteIfEmpty: Bool) throws {
        if try child._delete(path: tail, deleteIfEmpty: deleteIfEmpty) || (child.children.isEmpty && deleteIfEmpty) {
            child.removeFromParent()
        }
    }
}
