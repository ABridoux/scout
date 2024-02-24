//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - String

extension String: ExplorerValueConvertible {

    public func explorerValue() -> ExplorerValue { .string(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.string.unwrapOrThrow(.mismatchingType(String.self, value: explorerValue))
    }
}

// MARK: - Int

extension Int: ExplorerValueConvertible {

    public func explorerValue() -> ExplorerValue { .int(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.int.unwrapOrThrow(.mismatchingType(Int.self, value: explorerValue))
    }
}

// MARK: - Double

extension Double: ExplorerValueConvertible {

    public func explorerValue() -> ExplorerValue { .double(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.double.unwrapOrThrow(.mismatchingType(Double.self, value: explorerValue))
    }
}

// MARK: - Bool

extension Bool: ExplorerValueConvertible {

    public func explorerValue() -> ExplorerValue { .bool(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.bool.unwrapOrThrow(.mismatchingType(Bool.self, value: explorerValue))
    }
}

// MARK: - Data

extension Data: ExplorerValueConvertible {

    public func explorerValue() -> ExplorerValue { .data(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.data.unwrapOrThrow(.mismatchingType(Data.self, value: explorerValue))
    }
}

// MARK: - Array

extension Array: ExplorerValueConvertible where Element: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { try .array(map { try $0.explorerValue() })}

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.array
            .unwrapOrThrow(.mismatchingType([ExplorerValue].self, value: explorerValue))
            .map { try Element(from: $0) }
    }
}

// MARK: - Dictionary

extension Dictionary: ExplorerValueConvertible where Key == String, Value: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { try .dictionary(mapValues { try $0.explorerValue() })}

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.dictionary
            .unwrapOrThrow(.mismatchingType([String: ExplorerValue].self, value: explorerValue))
            .mapValues { try Value(from: $0) }
    }
}

// MARK: - Array with primitives

extension Array where Element == String {
    public func explorerValue() -> ExplorerValue { .array(map { $0.explorerValue() })}
}

extension Array where Element == Double {
    public func explorerValue() -> ExplorerValue { .array(map { $0.explorerValue() })}
}

extension Array where Element == Bool {
    public func explorerValue() -> ExplorerValue { .array(map { $0.explorerValue() })}
}

extension Array where Element == Data {
    public func explorerValue() -> ExplorerValue { .array(map { $0.explorerValue() })}
}

// MARK: - Dictionary with primitives

extension Dictionary where Key == String, Value == String {
    public func explorerValue() -> ExplorerValue { .dictionary(mapValues { $0.explorerValue() })}
}

extension Dictionary where Key == String, Value == Double {
    public func explorerValue() -> ExplorerValue { .dictionary(mapValues { $0.explorerValue() })}
}

extension Dictionary where Key == String, Value == Bool {
    public func explorerValue() -> ExplorerValue { .dictionary(mapValues { $0.explorerValue() })}
}

extension Dictionary where Key == String, Value == Data {
    public func explorerValue() -> ExplorerValue { .dictionary(mapValues { $0.explorerValue() })}
}
