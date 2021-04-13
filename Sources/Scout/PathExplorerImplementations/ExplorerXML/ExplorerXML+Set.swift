//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Set

extension ExplorerXML {

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try set(path: Slice(path), to: newValue)
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: newValue)
        return modified
    }

    private func set(path: SlicePath, to newValue: ExplorerValue) throws {
        guard let element = path.first else {
            try set(newValue: newValue)
            return
        }

        let remainder = path.dropFirst()
        let leftPart = remainder.leftPart

        try doSettingPath(leftPart) {
            switch element {
            case .key(let key):
                try getJaroWinkler(key: key).set(path: remainder, to: newValue)

            case .index(let index):
                let index = try computeIndex(from: index, arrayCount: childrenCount)
                try children[index].set(path: remainder, to: newValue)

            default: throw ExplorerError.wrongUsage(of: element)
            }
        }
    }

    private func set(newValue: ExplorerValue) throws {
        switch newValue {
        case .string(let string): set(value: string)
        case .int(let int), .count(let int): set(value: int.description)
        case .double(let double): set(value: double.description)
        case .bool(let bool): set(value: bool.description)
        case .data(let data): set(value: data.base64EncodedString())

        case .keysList(let keys):
            removeChildrenFromParent()
            let newChildren = keys.map { ExplorerXML(name: "key", value: $0) }
            addChildren(newChildren)

        case .array(let array), .slice(let array):
            removeChildrenFromParent()
            addChildren(array.map(ExplorerXML.init))

        case .dictionary(let dict), .filter(let dict):
            removeChildrenFromParent()
            let newChildren = dict.map { ExplorerXML(value: $0.value).with(name: $0.key) }
            addChildren(newChildren)
        }
    }
}

// MARK: - Set key name

extension ExplorerXML {

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        try set(path: Slice(path), keyNameTo: newKeyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> ExplorerXML {
        self
    }

    private func set(path: SlicePath, keyNameTo newKeyName: String) throws {
        guard let element = path.first else {
            set(name: newKeyName)
            return
        }

        let remainder = path.dropFirst()

        try doSettingPath(remainder.leftPart) {
            switch element {
            case .key(let key):
                try getJaroWinkler(key: key).set(path: remainder, keyNameTo: newKeyName)

            case .index(let index):
                let index = try computeIndex(from: index, arrayCount: childrenCount)
                try children[index].set(path: remainder, keyNameTo: newKeyName)

            default: throw ExplorerError.wrongUsage(of: element)
            }
        }
    }
}
