//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Wrap different structs to explore several format: Json, Plist and Xml
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

    // MARK: - Properties

    /// Non-nil if the key is of the `String` type
    var string: String? { get }

    /// Non-nil if the key is of the `Bool` type
    var bool: Bool? { get }

    /// Non-nil if the key is of the `Integer` type
    var int: Int? { get }

    /// Non-nil if the key is of the `Real` type
    var real: Double? { get }

    /// String representation of value property (if value is nil this is empty String).
    var stringValue: String { get }

    var format: DataFormat { get }

    /// The path leading to the PathExplorer: firstKey.secondKey[index].thirdKey...
    var readingPath: Path { get }

    // MARK: - Initialization

    init(data: Data) throws
    init(value: Any)

    // MARK: - Functions

    // MARK: Get

    /// Get the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    func get(_ path: Path) throws -> Self

    /// Get the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key), or the conversion is not possible
    func get<T: KeyAllowedType>(_ path: Path, as type: KeyType<T>) throws -> T

    // MARK: Set

    /// Set the value of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred. To force the `value`type, use the parameter `as type`
    mutating func set(_ path: Path, to newValue: Any) throws

    /// Set the value of the key at the given path
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter type: Try to force the conversion of the `value` parameter to the given type
    /// throwing an error if the conversion is not possible
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    /// - note: The type of the `value` parameter will be automatically inferred.
    mutating func set<Type: KeyAllowedType>(_ path: Path, to newValue: Any, as type: KeyType<Type>) throws

    // - Set key name

    /// Set the name of the key at the given path, specified as array
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary)
    mutating func set(_ path: Path, keyNameTo newKeyName: String) throws

    // MARK: Delete

    /// Delete the key at the given path, specified as array.
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws

    // MARK: Add

    /**
     Add a value at the given path, specified as array.

     #### Negative index
     It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.

     #### Appending
     To add a key at the end of an array, specify the `PathElement.count`

     ### Non-existing key
     Any non existing key encoutered in the path will be created.

     - Throws:When trying to add a named key to an array, or a indexed key to a dictionary
    */
    mutating func add(_ newValue: Any, at path: Path) throws

    /**
     Add a value at the given path, specified as array.

     #### Negative index
     It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.

     #### Appending
     To add a key at the end of an array, specify the `PathElement.count`

     ### Non-existing key
     Any non existing key encoutered in the path will be created.

     - parameter type: Try to force the conversion of the `value` parameter to the given type,
     throwing an error if the conversion is not possible
     - Throws:When trying to add a named key to an array, or a indexed key to a dictionary
    */
    mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws

    /**
     Add a value at the given path, specified as array.

     #### Negative index
     It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.

     #### Appending
     To add a key at the end of an array, specify the `PathElement.count`

     ### Non-existing key
     Any non existing key encoutered in the path will be created.

     - Throws:When trying to add a named key to an array, or a indexed key to a dictionary
    */
    mutating func add(_ newValue: Any, at path: PathElementRepresentable...) throws

    /**
     Add a value at the given path, specified as array.

     #### Negative index
     It's possible to specify a negative index to target the last nth element. For example, -1 targets the last element and -3 the last 3rd element.

     #### Appending
     To add a key at the end of an array, specify the `PathElement.count`

     ### Non-existing key
     Any non existing key encoutered in the path will be created.

     - parameter type: Try to force the conversion of the `value` parameter to the given type,
     throwing an error if the conversion is not possible
     - Throws:When trying to add a named key to an array, or a indexed key to a dictionary
    */
    mutating func add<Type: KeyAllowedType>(_ newValue: Any, at path: PathElementRepresentable..., as type: KeyType<Type>) throws

    // MARK: - Paths

    /// Returns all the paths leading to single or group values
    /// - Parameters:
    ///   - initialPath: Scope the return paths with this path as a starting point
    ///   - filter: Optionnally provide a filter on the key and/or value. Default is `noFilter`
    func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path]

    // MARK: Conversion

    /// Try to convert the value held by the PathExplorer to the given type
    func convertValue<Type: KeyAllowedType>(to type: KeyType<Type>) throws -> Type

    // MARK: Export

    /// Export the path explorer value to data
    func exportData() throws -> Data

    /// Export the path explorer value to a String
    func exportString() throws -> String

    /// Export the path explorer value to a CSV if possible. Use the default separator ';' if none specified
    func exportCSV(separator: String?) throws -> String

    /// Export the path explorer value to the specified format data with a default root name "root"
    func exportDataTo(_ format: DataFormat, rootName: String?) throws -> Data

    /// Export the path explorer value to the specified format string data with a default root name "root"
    func exportStringTo(_ format: DataFormat, rootName: String?) throws -> String

    /// Replace the group values (array or dictionaries) sub values by a unique one
    /// holding a fold mark to be replaced when exporting the string
    mutating func fold(upTo level: Int)
}
