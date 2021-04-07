//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct CodableFormatPathExplorer<Format: CodableFormat>: PathExplorerBis {
    private var value: ExplorerValue

    public var string: String? { value.string }
    public var bool: Bool? { value.bool }
    public var int: Int? { value.int }
    public var real: Double? { value.real }
    public var data: Data? { value.data }
    public func array<T>(of type: T.Type) throws -> [T] where T : ExplorerValueCreatable { try value.array(of: type) }
    public func dictionary<T>(of type: T.Type) throws -> [String : T] where T : ExplorerValueCreatable { try value.dictionary(of: type) }

    public var description: String { value.description }
    public var debugDescription: String { value.debugDescription }

    public init(value: ExplorerValue) {
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

    public func get(_ path: Path) throws -> Self {
        Self(value: try value.get(path))
    }

    public mutating func set(_ path: Path, to newValue: ExplorerValue) throws {
        try value.set(path, to: newValue)
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        try value.set(path, keyNameTo: newKeyName)
    }

    public func setting(_ path: Path, keyNameTo keyName: String) throws -> Self {
        Self(value: try value.setting(path, keyNameTo: keyName))
    }

    public func setting(_ path: Path, to newValue: ExplorerValue) throws -> Self {
        Self(value: try value.setting(path, to: newValue))
    }

    public mutating func delete(_ path: Path, deleteIfEmpty: Bool) throws {
        try value.delete(path, deleteIfEmpty: deleteIfEmpty)
    }

    public func deleting(_ path: Path, deleteIfEmpty: Bool) throws -> Self {
        Self(value: try value.deleting(path, deleteIfEmpty: deleteIfEmpty))
    }

    public mutating func add(_ value: ExplorerValue, at path: Path) throws {
        try self.value.add(value, at: path)
    }

    public func adding(_ value: ExplorerValue, at path: Path) throws -> Self {
        Self(value: try self.value.adding(value, at: path))
    }

    public func listPaths(startingAt initialPath: Path?, filter: PathsFilter) throws -> [Path] {
        try value.listPaths(startingAt: initialPath, filter: filter)
    }
}

extension CodableFormatPathExplorer: SerializablePathExplorer {

    public var format: DataFormat { Format.dataFormat }

    public init(data: Data) throws {
        value = try Format.decode(ExplorerValue.self, from: data)
    }

    public func exportData() throws -> Data {
        try Format.encode(value)
    }

    public func exportString() throws -> String {
        try String(data: exportData(), encoding: .utf8)
            .unwrapOrThrow(.dataToString)
    }

    public func exportData(to format: DataFormat, rootName: String?) throws -> Data {
        switch format {
        case .json: return try CodableFormats.JsonDefault.encode(value)
        case .plist: return try CodableFormats.PlistDefault.encode(value)
        case .yaml: return try CodableFormats.YamlDefault.encode(value)
        case .xml: return try CodableFormats.XmlDefault.encode(value)
        }
    }

    public func exportString(to format: DataFormat, rootName: String?) throws -> String {
        try String(data: exportData(to: format, rootName: rootName),
                   encoding: .utf8)
            .unwrapOrThrow(.dataToString)
    }

    public func exportCSV(separator: String?) throws -> String {
        try value.exportCSV(separator: separator ?? defaultCSVSeparator)
    }

    public mutating func fold(upTo level: Int) {
        fatalError()
    }
}