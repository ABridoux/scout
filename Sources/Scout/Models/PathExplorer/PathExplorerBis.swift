//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Wrap different structs to explore several format: Json, Plist and Xml
public protocol PathExplorerBis: CustomStringConvertible, CustomDebugStringConvertible,
    ExpressibleByStringLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral
where
    StringLiteralType == String,
    BooleanLiteralType == Bool,
    IntegerLiteralType == Int,
    FloatLiteralType == Double {

    // MARK: - Conversion

    /// Non `nil` if the key is of the `String` type
    var string: String? { get }

    /// Non `nil` if the key is of the `Bool` type
    var bool: Bool? { get }

    /// Non `nil` if the key is of the `Integer` type
    var int: Int? { get }

    /// Non `nil` if the key is of the `Double` type
    var real: Double? { get }

    /// Non `nil` if the key is of the `Data` type
    var data: Data? { get }

    /// An array of the provided type
    func array<T: ExplorerValueCreatable>(of type: T.Type) throws -> [T]

    /// A dictionary of the provided type as values.
    func dictionary<T: ExplorerValueCreatable>(of type: T.Type) throws -> [String: T]

    /// `true` if the explorer is a group value (e.g. a dictionary or an array)
    var isGroup: Bool { get }

    /// `true` if the explorer is a single value (e.g. a string, an int...)
    var isSingle: Bool { get }

    // MARK: - Initialization

    init(value: ExplorerValue)

    // MARK: - Get

    /// Get the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: Path) throws -> Self

    // MARK: - Set

    /// Set the value of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func set(_ path: Path, to newValue: ExplorerValue) throws

    /// Set the value of the key at the given path and returns a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self

    // MARK: - Set key name

    /// Set the name of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: Path, keyNameTo newKeyName: String) throws

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    func setting(_ path: Path, keyNameTo keyName: String) throws -> Self

    // MARK: - Delete

    /// Delete the key at the given path.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws

    /// Delete the key at the given path and return a new modified `PathExplorer`
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: Path, deleteIfEmpty: Bool) throws  -> Self

    // MARK: - Add

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
    mutating func add(_ value: ExplorerValue, at path: Path) throws

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
    func adding(_ value: ExplorerValue, at path: Path) throws -> Self

    // MARK: - Paths listing

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the returned paths with this path as a starting point
    ///   - filter: Optionally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path]
}
