//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// Wrap several structs to explore several format: Json, Plist, YAML and Xml
public protocol PathExplorer: CustomStringConvertible, CustomDebugStringConvertible,
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

    /// Non `nil` if the key is of the `Bool` type or of `Int` type with 0 or 1 for value
    var bool: Bool? { get }

    /// Non `nil` if the key is of the `Integer` type
    var int: Int? { get }

    /// Non `nil` if the key is of the `Double` type
    @available(*, deprecated, renamed: "double")
    var real: Double? { get }

    /// Non `nil` if the key is of the `Double` type
    var double: Double? { get }

    /// Non `nil` if the key is of the `Data` type
    var data: Data? { get }

    /// Non `nil` if the key is of the `Date` type
    var date: Date? { get }

    /// An array of the provided type
    func array<T: ExplorerValueCreatable>(of type: T.Type) throws -> [T]

    /// A dictionary of the provided type as values.
    func dictionary<T: ExplorerValueCreatable>(of type: T.Type) throws -> [String: T]

    /// `true` if the explorer is a group value (e.g. a dictionary or an array)
    ///
    /// For XML, `true` is the element has no children
    var isGroup: Bool { get }

    /// `true` if the explorer is a single value (e.g. a string, an int...)
    ///
    /// For XML, `true` is the element has nat least one child
    var isSingle: Bool { get }

    // MARK: - Initialization


    /// - Parameters:
    ///    - value: The value the explorer will take
    ///    - name: Optionally provide a name for a root element with Xml explorers
    init(value: ExplorerValue, name: String?)

    // MARK: - Get

    /// Get the key at the given path
    func get(_ path: Path) throws -> Self

    // MARK: - Set

    /// Set the value of the key at the given path
    mutating func set(_ path: Path, to newValue: ExplorerValue) throws

    /// Set the value of the key at the given path and returns a new modified `PathExplorer`
    func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self

    // MARK: - Set key name

    /// Set the name of the key at the given path
    mutating func set(_ path: Path, keyNameTo newKeyName: String) throws

    /// Set the name of the key at the given path, and return a new modified `PathExplorer`
    func setting(_ path: Path, keyNameTo keyName: String) throws -> Self

    // MARK: - Delete

    /// Delete the key at the given path.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws

    /// Delete the key at the given path and return a new modified `PathExplorer`
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion. Default: `false`
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func deleting(_ path: Path, deleteIfEmpty: Bool) throws  -> Self

    // MARK: - Add

    /// Add a value at the given path.
    ///
    /// #### Appending
    /// To add a key at the end of an array, specify ``PathElement/count``
    mutating func add(_ value: ExplorerValue, at path: Path) throws

    /// Add a value at the given path, and return a new modified `PathExplorer`
    ///
    /// ### Appending
    /// To add a key at the end of an array, specify the `PathElement.count`
    func adding(_ value: ExplorerValue, at path: Path) throws -> Self

    // MARK: - Paths listing

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the returned paths with this path as a starting point
    ///   - filter: Optionally provide a filter on the key and/or value. Default is ``PathsFilter/noFilter``
    func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path]
}
