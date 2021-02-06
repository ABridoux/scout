//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public extension PathExplorer {

    // MARK: - Get

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
    func get<T: KeyAllowedType>(_ elements: PathElement..., as type: KeyType<T>) throws -> T {
        try get(Path(elements), as: type)
    }

    // MARK: - Set

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
    mutating func set<Type: KeyAllowedType>(_ elements: PathElement..., to newValue: Any, as type: KeyType<Type>) throws {
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

    // MARK: - Delete

    /// Delete the key at the given path,specified as variadic `PathElement`s
    ///
    /// #### Negative index
    /// It's possible to specify a negative index to target the last nth element of an array. For example, -1 targets the last element and -3 the last 3rd element.
    ///
    /// - parameter deleteIfEmpty: When `true`, the dictionary or array holding the value will be deleted too if empty after the key deletion
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ elements: PathElement..., deleteIfEmpty: Bool = false) throws {
        try delete(Path(elements), deleteIfEmpty: deleteIfEmpty)
    }
}
