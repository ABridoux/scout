//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    public func get(_ path: Path) throws -> ExplorerXML {
        try get(path: Slice(path))
    }

    private func get(path: SlicePath) throws -> Self {
        guard let element = path.first else { return self }

        let remainder = path.dropFirst()
        let leftPart = remainder.leftPart
        let groupSample = leftPart.lastGroupSample

        return try doSettingPath(leftPart) {
            let next: ExplorerXML

            switch element {
            case .key(let key): next = try _get(key: key, groupSample: groupSample)
            case .index(let index): next = try get(index: index, groupSample: groupSample)
            case .count: next = getCount()
            case .keysList: next = getKeysList()
            case .filter(let pattern): next = try getFilter(with: pattern, groupSample: groupSample)
            case .slice(let bounds): next = try getSlice(within: bounds, groupSample: groupSample)
            }

            return try next.get(path: remainder)
        }
    }

    private func _get(key: String, groupSample: GroupSample?) throws -> Self {
        switch groupSample {
        case nil: return try getJaroWinkler(key: key)

        case .slice, .filter:
            return try copyMappingChildren {
                try $0._get(key: key, groupSample: nil).with(name: "\($0.name)_\(key)")
            }
        }
    }

    private func get(index: Int, groupSample: GroupSample?) throws -> Self {
        switch groupSample {
        case nil:
            let index = try computeIndex(from: index, arrayCount: children.count)
            return children[index]

        case .slice, .filter: return try copyMappingChildren { try $0.get(index: index, groupSample: nil) }
        }
    }

    private func getCount() -> Self {
        ExplorerXML(name: "count", value: childrenCount.description)
    }

    private func getKeysList() -> Self {
        let copy = copyWithoutChildren()
        children.map(\.name).forEach { key in
            let newChild = ExplorerXML(name: "key", value: key)
            copy.addChild(newChild)
        }
        return copy
    }

    private func getFilter(with pattern: String, groupSample: GroupSample?) throws -> Self {
        switch groupSample {
        case nil:
            let regex = try NSRegularExpression(with: pattern)
            let copy = copyWithoutChildren()
            children
                .filter { regex.validate($0.name) }
                .forEach { copy.addChild($0) }

            return copy

        case .slice, .filter: return try copyMappingChildren { try $0.getFilter(with: pattern, groupSample: nil) }
        }
    }

    private func getSlice(within bounds: Bounds, groupSample: GroupSample?) throws -> Self {
        switch groupSample {
        case nil:
            let range = try bounds.range(arrayCount: childrenCount)
            let copy = copyWithoutChildren()
            children[range].forEach { copy.addChild($0) }
            return copy

        case .slice, .filter:
            return try copyMappingChildren { try $0.getSlice(within: bounds, groupSample: nil) }
        }
    }
}
