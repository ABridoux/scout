//
// Scout
// Copyright (c) Alexis Bridoux 2020
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
        guard let (head, tail) = path.cutHead() else { return true }

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
        if try next._delete(path: tail, deleteIfEmpty: deleteIfEmpty) || (next.children.isEmpty && deleteIfEmpty) {
            next.removeFromParent()
        }
    }

    private func delete(index: Int, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let index = try computeIndex(from: index, arrayCount: childrenCount)
        let next = children[index]
        if try next._delete(path: tail, deleteIfEmpty: deleteIfEmpty) || (next.children.isEmpty && deleteIfEmpty) {
            next.removeFromParent()
        }
    }

    private func deleteFilter(with pattern: String, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let regex = try NSRegularExpression(with: pattern)
        try children
            .filter { regex.validate($0.name) }
            .forEach { child in
                if try child._delete(path: tail, deleteIfEmpty: deleteIfEmpty) || (child.children.isEmpty && deleteIfEmpty) {
                    child.removeFromParent()
                }
            }
    }

    private func deleteSlice(within bounds: Bounds, deleteIfEmpty: Bool, tail: SlicePath) throws {
        let range = try bounds.range(arrayCount: childrenCount)
        try children[range].forEach { child in
            if try child._delete(path: tail, deleteIfEmpty: deleteIfEmpty) || (child.children.isEmpty && deleteIfEmpty) {
                child.removeFromParent()
            }
        }
    }
}
