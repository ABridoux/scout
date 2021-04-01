//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public extension PathExplorerBis {

    func get(_ path: [PathElement]) throws -> Self { try get(Path(path)) }
    func get(_ path: PathElement...) throws -> Self { try get(path) }

    mutating func set(_ path: [PathElement], to newValue: ValueType) throws { try set(Path(path), to: newValue) }
    mutating func set(_ path: PathElement..., to newValue: ValueType) throws { try set(path, to: newValue) }

    mutating func set(_ path: [PathElement], keyNameTo newKeyName: String) throws { try set(Path(path), keyNameTo: newKeyName) }
    mutating func set(_ path: PathElement..., keyNameTo newKeyName: String) throws { try set(path, keyNameTo: newKeyName) }

}
