//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// A `PathExplorer` using an `ExplorerValue` and can be encoded/decoded with the provided `CodableFormat`
public struct CodablePathExplorer<Format: CodableFormat>: PathExplorer {

    // MARK: - Properties

    private(set) var value: ExplorerValue

    public var string: String? { value.string }
    public var bool: Bool? { value.bool }
    public var int: Int? { value.int }
    @available(*, deprecated, renamed: "double")
    public var real: Double? { value.real }
    public var double: Double? { value.double }
    public var data: Data? { value.data }
    public func array<T>(of type: T.Type) throws -> [T] where T: ExplorerValueCreatable { try value.array(of: type) }
    public func dictionary<T>(of type: T.Type) throws -> [String: T] where T: ExplorerValueCreatable { try value.dictionary(of: type) }

    public var isGroup: Bool { value.isGroup }
    public var isSingle: Bool { value.isSingle }

    public var description: String { value.description }
    public var debugDescription: String { value.debugDescription }

    // MARK: - Initialization

    public init(value: ExplorerValue, name: String?) {
        self.value = value
    }

    public init(stringLiteral value: String) {
        self.value = ExplorerValue(stringLiteral: value)
    }

    public init(booleanLiteral value: Bool) {
        self.value = ExplorerValue(booleanLiteral: value)
    }

    public init(integerLiteral value: Int) {
        self.value = ExplorerValue(integerLiteral: value)
    }

    public init(floatLiteral value: Double) {
        self.value = ExplorerValue(floatLiteral: value)
    }

    // MARK: - Functions

    public func get(_ path: Path) throws -> Self {
        Self(value: try value.get(path))
    }

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try value.set(path, to: newValue)
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        try value.set(path, keyNameTo: newKeyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> Self {
        Self(value: try value.setting(path, keyNameTo: keyName))
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self {
        Self(value: try value.setting(path, to: newValue))
    }

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        try value.delete(path, deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> Self {
        Self(value: try value.deleting(path, deleteIfEmpty: deleteIfEmpty))
    }

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        try self.value.add(value, at: path)
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> Self {
        Self(value: try self.value.adding(value, at: path))
    }

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        try value.listPaths(startingAt: initialPath, filter: filter)
    }
}

extension CodablePathExplorer: EquatablePathExplorer {

    func isEqual(to other: CodablePathExplorer<Format>) -> Bool {
        value.isEqual(to: other.value)
    }
}
