//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
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
        guard let element = path.first else { return true }

        let remainder = path.dropFirst()

        try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key): try delete(key: key, deleteIfEmpty: deleteIfEmpty, remainder: remainder)
            case .index(let index): try delete(index: index, deleteIfEmpty: deleteIfEmpty, remainder: remainder)
            case .filter(let pattern): try deleteFilter(with: pattern, deleteIfEmpty: deleteIfEmpty, remainder: remainder)
            case .slice(let bounds): try deleteSlice(within: bounds, deleteIfEmpty: deleteIfEmpty, remainder: remainder)
            case .count, .keysList:
                throw ExplorerError.wrongUsage(of: element)
            }
        }

        return false
    }

    // MARK: PathElement

    private func delete(key: String, deleteIfEmpty: Bool, remainder: SlicePath) throws {
        let next = try getJaroWinkler(key: key)
        if try next._delete(path: remainder, deleteIfEmpty: deleteIfEmpty) || (next.children.isEmpty && deleteIfEmpty) {
            next.removeFromParent()
        }
    }

    private func delete(index: Int, deleteIfEmpty: Bool, remainder: SlicePath) throws {
        let index = try computeIndex(from: index, arrayCount: childrenCount)
        let next = children[index]
        if try next._delete(path: remainder, deleteIfEmpty: deleteIfEmpty) || (next.children.isEmpty && deleteIfEmpty) {
            next.removeFromParent()
        }
    }

    private func deleteFilter(with pattern: String, deleteIfEmpty: Bool, remainder: SlicePath) throws {
        let regex = try NSRegularExpression(with: pattern)
        try children
            .filter { regex.validate($0.name) }
            .forEach { child in
                if try child._delete(path: remainder, deleteIfEmpty: deleteIfEmpty) || (child.children.isEmpty && deleteIfEmpty) {
                    child.removeFromParent()
                }
            }
    }

    private func deleteSlice(within bounds: Bounds, deleteIfEmpty: Bool, remainder: SlicePath) throws {
        let range = try bounds.range(arrayCount: childrenCount)
        try children[range].forEach { child in
            if try child._delete(path: remainder, deleteIfEmpty: deleteIfEmpty) || (child.children.isEmpty && deleteIfEmpty) {
                child.removeFromParent()
            }
        }
    }
}
