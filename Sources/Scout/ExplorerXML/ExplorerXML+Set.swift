//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Set

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try _set(path: Slice(path), to: .explorerValue(newValue))
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: newValue)
        return modified
    }

    /// Set the path to the given AEXMLElement rather than an `ExplorerValue`
    public mutating func set(_ path: Path, to newElement: Element) throws {
        try _set(path: Slice(path), to: .xmlElement(newElement))
    }

    /// Set the path to the given AEXMLElement rather than an `ExplorerValue`
    public func setting(_ path: Path, to newElement: Element) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: newElement)
        return modified
    }

    // MARK: General function

    private func _set(path: SlicePath, to newValue: ValueSetter) throws {
        guard let (head, tail) = path.cutHead() else {
            set(value: newValue)
            return
        }

        try doSettingPath(tail.leftPart) {
            switch head {
            case .key(let key):
                try getJaroWinkler(key: key)._set(path: tail, to: newValue)

            case .index(let index):
                let index = try computeIndex(from: index, arrayCount: childrenCount)
                try children[index]._set(path: tail, to: newValue)

            default: throw ExplorerError.wrongUsage(of: head)
            }
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

        let tail = path.dropFirst()

        try doSettingPath(tail.leftPart) {
            switch element {
            case .key(let key):
                try getJaroWinkler(key: key).set(path: tail, keyNameTo: newKeyName)

            case .index(let index):
                let index = try computeIndex(from: index, arrayCount: childrenCount)
                try children[index].set(path: tail, keyNameTo: newKeyName)

            default: throw ExplorerError.wrongUsage(of: element)
            }
        }
    }
}
