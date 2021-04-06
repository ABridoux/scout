//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Protocols

/// Can be represented as an `ExplorerValue`
/// - note: Default implementation provided for types conforming to `Encodable`
public protocol ExplorerValueRepresentable {

    func explorerValue() throws -> ExplorerValue
}

/// Can be instantiated from an `ExplorerValue`
/// - note: Default implementation provided for types conforming to `Decodable`
public protocol ExplorerValueCreatable {

    init(from explorerValue: ExplorerValue) throws
}

/// Can be represented as and instantiated from as `ExplorerValue`
/// - note: Default implementation provided for types conforming to `Codable`
public typealias ExplorerValueConvertible = ExplorerValueRepresentable & ExplorerValueCreatable

// MARK: - Codable implementations

public extension ExplorerValueRepresentable where Self: Encodable {

    func explorerValue() throws -> ExplorerValue {
        let encoder = ExplorerValueEncoder()
        try encode(to: encoder)
        return encoder.value
    }
}

public extension ExplorerValueCreatable where Self: Decodable {

    init(from explorerValue: ExplorerValue) throws {
        let decoder = ExplorerValueDecoder(explorerValue)
        try self.init(from: decoder)
    }
}
