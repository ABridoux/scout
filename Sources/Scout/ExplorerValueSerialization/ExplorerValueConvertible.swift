//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - ExplorerValueRepresentable

/// Can be represented as an `ExplorerValue`
/// - note: Default implementation provided for types conforming to `Encodable`
public protocol ExplorerValueRepresentable {

    /// Convert `self` to an ``ExplorerValue``
    func explorerValue() throws -> ExplorerValue
}

// MARK: - ExplorerValueCreatable

/// Can be instantiated from an ``ExplorerValue``
/// - note: Default implementation provided for types conforming to `Decodable`
public protocol ExplorerValueCreatable {

    /// Instantiate a new value from an ``ExplorerValue``
    init(from explorerValue: ExplorerValue) throws
}

// MARK: - ExplorerValueConvertible

/// Can be represented *as* and instantiated *from* an ``ExplorerValue``
/// - note: Default implementation provided for types conforming to `Codable`
public typealias ExplorerValueConvertible = ExplorerValueRepresentable & ExplorerValueCreatable

// MARK: - Encodable

public extension ExplorerValueRepresentable where Self: Encodable {

    func explorerValue() throws -> ExplorerValue {
        let encoder = ExplorerValueEncoder()
        try encode(to: encoder)
        return encoder.value
    }
}

// MARK: - Decodable

public extension ExplorerValueCreatable where Self: Decodable {

    init(from explorerValue: ExplorerValue) throws {
        let decoder = ExplorerValueDecoder(explorerValue)
        try self.init(from: decoder)
    }
}
