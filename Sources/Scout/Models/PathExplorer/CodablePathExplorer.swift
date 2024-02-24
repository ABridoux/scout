//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - CodablePathExplorer

/// A  concrete implementation of `PathExplorer` with a specific ``CodableFormat``.
///
/// - note: Mainly a wrapper around ``ExplorerValue`` to offer a unified interface for all `Codable` `PathExplorer`s
public struct CodablePathExplorer<Format: CodableFormat>: PathExplorer {

    // MARK: Properties

    private(set) var value: ExplorerValue

    // MARK: Computed

    public var string: String? { value.string }
    public var bool: Bool? { value.bool }
    public var int: Int? { value.int }
    @available(*, deprecated, renamed: "double")
    public var real: Double? { value.real }
    public var double: Double? { value.double }
    public var data: Data? { value.data }
    public var date: Date? { value.date }
    public func array<T>(of type: T.Type) throws -> [T] where T: ExplorerValueCreatable { try value.array(of: type) }
    public func dictionary<T>(of type: T.Type) throws -> [String: T] where T: ExplorerValueCreatable { try value.dictionary(of: type) }

    public var isGroup: Bool { value.isGroup }
    public var isSingle: Bool { value.isSingle }

    public var description: String { value.description }
    public var debugDescription: String { value.debugDescription }

    // MARK: Init

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
}

// MARK: - Get

extension CodablePathExplorer {

    public func get(_ path: Path) throws -> Self {
        Self(value: try value.get(path))
    }

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try value.set(path, to: newValue)
    }
}

// MARK: - Set

extension CodablePathExplorer {

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        try value.set(path, keyNameTo: newKeyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> Self {
        Self(value: try value.setting(path, keyNameTo: keyName))
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self {
        Self(value: try value.setting(path, to: newValue))
    }
}

// MARK: - Delete

extension CodablePathExplorer {

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        try value.delete(path, deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> Self {
        Self(value: try value.deleting(path, deleteIfEmpty: deleteIfEmpty))
    }
}

// MARK: - Add

extension CodablePathExplorer {

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        try self.value.add(value, at: path)
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> Self {
        Self(value: try self.value.adding(value, at: path))
    }
}

// MARK: - List paths

extension CodablePathExplorer {

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        try value.listPaths(startingAt: initialPath, filter: filter)
    }
}

// MARK: - EquatablePathExplorer

extension CodablePathExplorer: EquatablePathExplorer {

    func isEqual(to other: CodablePathExplorer<Format>) -> Bool {
        value.isEqual(to: other.value)
    }
}
