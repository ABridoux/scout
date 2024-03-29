//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Convenience init

public extension PathExplorer {

    /// Same as ``init(value:name:)`` with a default `nil` value for `name`
    init(value: ExplorerValue) {
        self.init(value: value, name: nil)
    }
}

// MARK: - Get

public extension PathExplorer {

    /// Get the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: [PathElement]) throws -> Self { try get(Path(path)) }

    /// Get the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: PathElement...) throws -> Self { try get(path) }
}

// MARK: - Set

public extension PathExplorer {

    // MARK: Mutating

    /// Set the value of the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func set(_ path: PathElement..., to newValue: ExplorerValue) throws { try set(Path(path), to: newValue) }

    // MARK: Mutating ExplorerValueRepresentable

    /// Set the provided `ExplorerValueRepresentable`value of the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or if the `newValue.explorerValue()` function fails
    mutating func set(_ path: Path, to newValue: ExplorerValueRepresentable) throws {
        try set(path, to: newValue.explorerValue())
    }

    /// Set the provided `ExplorerValueRepresentable`value of the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or if the `newValue.explorerValue()` function fails
    mutating func set(_ path: PathElement..., to newValue: ExplorerValueRepresentable) throws {
        try set(Path(path), to: newValue.explorerValue())
    }

    // MARK: Non mutating

    /// Set the value of the key at the given path and return a new modified `PathExplorer`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func setting(_ path: PathElement..., to newValue: ExplorerValue) throws -> Self { try setting(Path(path), to: newValue) }

    /// Set the value of the key at the given path and return a new modified `PathExplorer`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or if the `newValue.explorerValue()` function fails
    func setting(_ path: Path, to newValue: ExplorerValueRepresentable) throws -> Self { try setting(path, to: newValue.explorerValue()) }

    /// Set the value of the key at the given path and return a new modified `PathExplorer`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or if the `newValue.explorerValue()` function fails
    func setting(_ path: PathElement..., to newValue: ExplorerValueRepresentable) throws -> Self { try setting(Path(path), to: newValue.explorerValue()) }
}

// MARK: - Set key name

public extension PathExplorer {

    /// Set the name of the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: [PathElement], keyNameTo newKeyName: String) throws { try set(Path(path), keyNameTo: newKeyName) }

    /// Set the name of the key at the given path
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: PathElement..., keyNameTo newKeyName: String) throws { try set(path, keyNameTo: newKeyName) }

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    func setting(_ path: [PathElement], keyNameTo newKeyName: String) throws -> Self { try setting(Path(path), keyNameTo: newKeyName) }

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    func setting(_ path: PathElement..., keyNameTo newKeyName: String) throws -> Self { try setting(path, keyNameTo: newKeyName) }
}

// MARK: - Delete

public extension PathExplorer {

    /// Delete the key at the given path.
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path) throws { try delete(Path(path), deleteIfEmpty: false) }

    /// Delete the key at the given path.
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: [PathElement], deleteIfEmpty: Bool = false) throws { try delete(Path(path), deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path.
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: PathElement..., deleteIfEmpty: Bool = false) throws { try delete(path, deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path and return a new modified `PathExplorer`
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: [PathElement], deleteIfEmpty: Bool = false) throws -> Self { try deleting(Path(path), deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path and return a new modified `PathExplorer`
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: PathElement..., deleteIfEmpty: Bool = false) throws -> Self { try deleting(path, deleteIfEmpty: deleteIfEmpty) }
}

// MARK: - Add

public extension PathExplorer {

    // MARK: Mutating

    /// Add a value at the given path.
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify  ``PathElement/count``
    mutating func add(_ value: ExplorerValue, at path: PathElement...) throws { try add(value, at: Path(path)) }

    /// Add a value at the given path.
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify ``PathElement/count``
    /// - Throws: If the `newValue.explorerValue` function fails
    mutating func add(_ value: ExplorerValueRepresentable, at path: Path) throws { try add(value.explorerValue(), at: path) }

    /// Add a value at the given path.
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify ``PathElement/count``
    /// - Throws: If the `newValue.explorerValue()` function fails
    mutating func add(_ value: ExplorerValueRepresentable, at path: PathElement...) throws { try add(value.explorerValue(), at: Path(path)) }

    // MARK: Non mutating

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify ``PathElement/count``
    func adding(_ value: ExplorerValue, at path: PathElement...) throws -> Self { try adding(value, at: Path(path)) }

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify ``PathElement/count``
    /// - Throws: If the `newValue.explorerValue()` function fails
    func adding(_ value: ExplorerValueRepresentable, at path: Path) throws -> Self { try adding(value.explorerValue(), at: path) }

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify  ``PathElement/count``
    /// - Throws: If the `newValue.explorerValue()` function fails
    func adding(_ value: ExplorerValueRepresentable, at path: PathElement...) throws -> Self { try adding(value.explorerValue(), at: Path(path)) }
}

// MARK: - Paths listing

public extension PathExplorer {

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the returned paths with this path as a starting point
    ///   - filter: Optionally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt initialPath: Path? = nil) throws -> [Path] {
        try listPaths(startingAt: initialPath, filter: .noFilter)
    }

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the returned paths with this path as a starting point
    ///   - filter: Optionally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt elements: PathElement..., filter: PathsFilter = .noFilter) throws -> [Path] {
        try listPaths(startingAt: Path(elements), filter: filter)
    }
}
