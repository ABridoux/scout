//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Set

extension ExplorerXML {

    // MARK: PathExplorer

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        if referenceIsShared() { self = copy() }
        try _set(path: Slice(path), to: .explorerValue(newValue))
    }

    /// Set the path to the given `AEXMLElement` value rather than an `ExplorerValue`
    public mutating func set(_ path: Path, to element: Element) throws {
        try _set(path: Slice(path), to: .explorerXML(ExplorerXML(element: element)))
    }

    /// Set the path to the given `ExplorerXML` value rather than an `ExplorerValue`
    public mutating func set(_ path: Path, to explorer: ExplorerXML) throws {
        try _set(path: Slice(path), to: .explorerXML(explorer))
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: newValue)
        return modified
    }

    /// Set the path to the given `AEXMLElement` value rather than an `ExplorerValue`
    public func setting(_ path: Path, to element: Element) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: element)
        return modified
    }

    /// Set the path to the given `ExplorerXML` value  rather than an `ExplorerValue`
    public func setting(_ path: Path, to explorer: ExplorerXML) throws -> ExplorerXML {
        var modified = copy()
        try modified.set(path, to: explorer)
        return modified
    }

    // MARK: General function

    private func _set(path: SlicePath, to newValue: ValueSetter) throws {
        guard let (head, tail) = path.headAndTail() else {
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
