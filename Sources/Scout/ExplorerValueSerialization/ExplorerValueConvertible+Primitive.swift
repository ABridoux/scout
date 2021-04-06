//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension String: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { .string(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.string.unwrapOrThrow(.mismatchingType(String.self, value: explorerValue))
    }
}

extension Int: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { .int(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.int.unwrapOrThrow(.mismatchingType(Int.self, value: explorerValue))
    }
}

extension Double: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { .double(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.double.unwrapOrThrow(.mismatchingType(Double.self, value: explorerValue))
    }
}

extension Bool: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { .bool(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.bool.unwrapOrThrow(.mismatchingType(Bool.self, value: explorerValue))
    }
}

extension Data: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { .data(self) }

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.data.unwrapOrThrow(.mismatchingType(Data.self, value: explorerValue))
    }
}

extension Array: ExplorerValueConvertible where Element: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { try .array(map { try $0.explorerValue() })}

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.array
            .unwrapOrThrow(.mismatchingType([ExplorerValue].self, value: explorerValue))
            .map { try Element(from: $0) }
    }
}

extension Dictionary: ExplorerValueConvertible where Key == String, Value: ExplorerValueConvertible {

    public func explorerValue() throws -> ExplorerValue { try .dictionary(mapValues { try $0.explorerValue() })}

    public init(from explorerValue: ExplorerValue) throws {
        self = try explorerValue.dictionary
            .unwrapOrThrow(.mismatchingType([String: ExplorerValue].self, value: explorerValue))
            .mapValues { try Value(from: $0) }
    }
}
