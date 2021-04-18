//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    // MARK: - PathExplorer

    public func get(_ path: Path) throws -> ExplorerXML {
        try _get(path: Slice(path))
    }

    // MARK: General function

    private func _get(path: SlicePath) throws -> Self {
        guard let head = path.first else { return self }
        let tail = path.dropFirst()

        return try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key): return try get(key: key, tail: tail)
            case .index(let index): return  try get(index: index, tail: tail)
            case .count: return try getCount(tail: tail)
            case .keysList: return try getKeysList(tail: tail)
            case .filter(let pattern): return try getFilter(with: pattern, tail: tail)
            case .slice(let bounds): return try getSlice(within: bounds, tail: tail)
            }
        }
    }

    // MARK: PathElement

    private func get(key: String, tail: SlicePath) throws -> Self {
        do {
            return try getJaroWinkler(key: key)._get(path: tail)
        } catch {
            if let attribute = attribute(named: key) {
                return try ExplorerXML(name: key, value: attribute)._get(path: tail)
            } else {
                throw error
            }
        }
    }

    private func get(index: Int, tail: SlicePath) throws -> Self {
        let index = try computeIndex(from: index, arrayCount: children.count)
        return try children[index]._get(path: tail)
    }

    private func getCount(tail: SlicePath) throws -> Self {
        try ExplorerXML(name: "count", value: childrenCount.description)._get(path: tail)
    }

    private func getKeysList(tail: SlicePath) throws -> Self {
        let copy = copyWithoutChildren()

        children.map(\.name).forEach { key in
            let newChild = ExplorerXML(name: "key", value: key)
            copy.addChild(newChild)
        }

        return try copy
            .with(name: "\(name)_keys")
            ._get(path: tail)
    }

    private func getFilter(with pattern: String, tail: SlicePath) throws -> Self {
        let regex = try NSRegularExpression(with: pattern)
        var copy = copyWithoutChildren()

        copy.children = try children
            .lazy
            .filter { regex.validate($0.name) }
            .map { try $0._get(path: tail).with(name: $0.name) }

        return copy
    }

    private func getSlice(within bounds: Bounds, tail: SlicePath) throws -> Self {
        let range = try bounds.range(arrayCount: childrenCount)
        var copy = copyWithoutChildren()
        copy.children = try children[range].map { try $0._get(path: tail) }
        return copy
    }
}
