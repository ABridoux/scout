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
    func setting(_ path: [PathElement], to newValue: ValueType) throws -> Self { try setting(Path(path), to: newValue) }
    func setting(_ path: PathElement..., to newValue: ValueType) throws -> Self { try setting(path, to: newValue) }

    mutating func set(_ path: [PathElement], keyNameTo newKeyName: String) throws { try set(Path(path), keyNameTo: newKeyName) }
    mutating func set(_ path: PathElement..., keyNameTo newKeyName: String) throws { try set(path, keyNameTo: newKeyName) }
    func setting(_ path: [PathElement], keyNameTo newKeyName: String) throws -> Self { try setting(Path(path), keyNameTo: newKeyName) }
    func setting(_ path: PathElement..., keyNameTo newKeyName: String) throws -> Self { try setting(path, keyNameTo: newKeyName) }

    mutating func delete(_ path: Path) throws { try delete(Path(path), deleteIfEmpty: false) }
    mutating func delete(_ path: [PathElement], deleteIfEmpty: Bool = false) throws { try delete(Path(path), deleteIfEmpty: deleteIfEmpty) }
    mutating func delete(_ path: PathElement..., deleteIfEmpty: Bool = false) throws { try delete(path, deleteIfEmpty: deleteIfEmpty) }
    func deleting(_ path: [PathElement], deleteIfEmpty: Bool = false) throws -> Self { try deleting(Path(path), deleteIfEmpty: deleteIfEmpty) }
    func deleting(_ path: PathElement..., deleteIfEmpty: Bool = false) throws -> Self { try deleting(path, deleteIfEmpty: deleteIfEmpty) }

    mutating func add(_ value: ValueType, at path: [PathElement]) throws { try add(value, at: Path(path)) }
    mutating func add(_ value: ValueType, at path: PathElement...) throws { try add(value, at: path) }
    func adding(_ value: ValueType, at path: [PathElement]) throws -> Self { try adding(value, at: Path(path)) }
    func adding(_ value: ValueType, at path: PathElement...) throws -> Self { try adding(value, at: path) }
}
