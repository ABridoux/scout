//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Get

public extension PathExplorerBis {

    /// Get the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: [PathElement]) throws -> Self { try get(Path(path)) }

    /// Get the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: PathElement...) throws -> Self { try get(path) }
}

// MARK: - Set

public extension PathExplorerBis {

    /// Set the value of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    mutating func set(_ path: [PathElement], to newValue: ValueType) throws { try set(Path(path), to: newValue) }

    /// Set the value of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    mutating func set(_ path: PathElement..., to newValue: ValueType) throws { try set(path, to: newValue) }

    /// Set the value of the key at the given path, and return the modified explorer
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    func setting(_ path: [PathElement], to newValue: ValueType) throws -> Self { try setting(Path(path), to: newValue) }

    /// Set the value of the key at the given path and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    func setting(_ path: PathElement..., to newValue: ValueType) throws -> Self { try setting(path, to: newValue) }
}

// MARK: - Set key name

public extension PathExplorerBis {

    /// Set the name of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: [PathElement], keyNameTo newKeyName: String) throws { try set(Path(path), keyNameTo: newKeyName) }

    /// Set the name of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: PathElement..., keyNameTo newKeyName: String) throws { try set(path, keyNameTo: newKeyName) }

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    func setting(_ path: [PathElement], keyNameTo newKeyName: String) throws -> Self { try setting(Path(path), keyNameTo: newKeyName) }

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    func setting(_ path: PathElement..., keyNameTo newKeyName: String) throws -> Self { try setting(path, keyNameTo: newKeyName) }
}

// MARK: - Delete

public extension PathExplorerBis {

    /// Delete the key at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path) throws { try delete(Path(path), deleteIfEmpty: false) }

    /// Delete the key at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: [PathElement], deleteIfEmpty: Bool = false) throws { try delete(Path(path), deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: PathElement..., deleteIfEmpty: Bool = false) throws { try delete(path, deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: [PathElement], deleteIfEmpty: Bool = false) throws -> Self { try deleting(Path(path), deleteIfEmpty: deleteIfEmpty) }

    /// Delete the key at the given path and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: PathElement..., deleteIfEmpty: Bool = false) throws -> Self { try deleting(path, deleteIfEmpty: deleteIfEmpty) }
}

// MARK: - Add

public extension PathExplorerBis {

    /// Add a value at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encountered in the path will be created.
    mutating func add(_ value: ValueType, at path: [PathElement]) throws { try add(value, at: Path(path)) }

    /// Add a value at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encountered in the path will be created.
    mutating func add(_ value: ValueType, at path: PathElement...) throws { try add(value, at: path) }

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encountered in the path will be created.
    func adding(_ value: ValueType, at path: [PathElement]) throws -> Self { try adding(value, at: Path(path)) }

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encountered in the path will be created.
    func adding(_ value: ValueType, at path: PathElement...) throws -> Self { try adding(value, at: path) }
}

// MARK: - Paths listing

public extension PathExplorerBis {

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
        try listPaths(startingAt: Path(elements), filter: .noFilter)
    }
}
