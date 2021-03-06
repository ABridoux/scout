//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Properties

public extension PathExplorer {

    /// `real` property for convenience naming
    var double: Double? { real }
}

// MARK: - Get

public extension PathExplorer {

    /// Get the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ elements: PathElement...) throws -> Self {
        try get(Path(elements))
    }

    // MARK: Force type

    /// Get the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or the conversion is not possible
    func get<T: KeyAllowedType>(_ elements: PathElement..., as type: KeyTypes.KeyType<T>) throws -> T {
        try get(Path(elements), as: type)
    }
}

// MARK: - Set

public extension PathExplorer {

    /// Set the value of the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    mutating func set(_ elements: PathElement..., to newValue: Any) throws {
        try set(Path(elements), to: newValue)
    }

    // MARK: Force type

    /// Set the value of the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter type: Try to force the conversion of the `value` parameter to the given type,
    /// throwing an error if the conversion is not possible
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred.
    mutating func set<Type: KeyAllowedType>(_ elements: PathElement..., to newValue: Any, as type: KeyTypes.KeyType<Type>) throws {
        try set(Path(elements), to: newValue, as: type)
    }

    // MARK: Set key name

    /// Set the name of the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func set(_ elements: PathElement..., keyNameTo newKeyName: String) throws {
        try set(Path(elements), keyNameTo: newKeyName)
    }
}

// MARK: - Delete

public extension PathExplorer {

    /// Delete the key at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path) throws {
        try delete(path, deleteIfEmpty: false)
    }

    /// Delete the key at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ elements: PathElement..., deleteIfEmpty: Bool = false) throws {
        try delete(Path(elements), deleteIfEmpty: deleteIfEmpty)
    }
}

// MARK: - Add

public extension PathExplorer {

    /// Add a value at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encoutered in the path will be created.
    mutating func add(_ newValue: Any, at elements: PathElement...) throws {
        try add(newValue, at: Path(elements))
    }

    /// Add a value at the given path, specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    ///
    /// ### Non-existing key
    /// Any non existing key encoutered in the path will be created.
    ///
    /// - parameter type: Try to force the conversion of the `value` parameter to the given type,
    /// throwing an error if the conversion is not possible
    mutating func add<Type: KeyAllowedType>(_ newValue: Any, at elements: PathElement..., as type: KeyTypes.KeyType<Type>) throws {
        try add(newValue, at: Path(elements), as: type)
    }
}

// MARK: - Paths list

extension PathExplorer {

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the return paths with this path as a starting point
    ///   - filter: Optionnally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt initialPath: Path? = nil) throws -> [Path] {
        try listPaths(startingAt: initialPath, filter: .noFilter)
    }

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the return paths with this path as a starting point
    ///   - filter: Optionnally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt elements: PathElement..., filter: PathsFilter = .noFilter) throws -> [Path] {
        try listPaths(startingAt: Path(elements), filter: .noFilter)
    }
}

// MARK: - Export

extension PathExplorer {

    var defaultCSVSeparator: String { ";" }

    /// Export the path explorer value to a CSV if possible. Use the default separator ';' if none specified
    public func exportCSV() throws -> String {
        try exportCSV(separator: nil)
    }

    /// Export the path explorer value to the specified format data
    public func exportData(to format: DataFormat) throws -> Data {
        try exportData(to: format, rootName: nil)
    }

    /// Export the path explorer value to the specified format string data
    public func exportString(to format: DataFormat) throws -> String {
        try exportString(to: format, rootName: nil)
    }
}
