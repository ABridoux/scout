//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// A value can take a type conforming to this protocol
public protocol KeyAllowedType: LosslessStringConvertible, Hashable {

    static var typeDescription: String { get }
}

extension KeyAllowedType {

    /// Try to instantiate a type with the given value
    init(value: Any) throws {
        if let convertedValue = value as? Self {
            self = convertedValue
            return
        }

        guard let stringValue = (value as? CustomStringConvertible)?.description else {
            throw PathExplorerError.valueConversionError(value: String(describing: value), type: String(describing: Self.typeDescription))
        }

        if Self.self == Bool.self {
            // specific case for Bool values as we allow other string than "true" or "false"
            if Bool.trueSet.contains(stringValue) {
                self = try Self(value: true)
                return
            } else if Bool.falseSet.contains(stringValue) {
                self = try Self(value: false)
                return
            }
        } else if let convertedValue = Self(stringValue) {
            self = convertedValue
            return
        }

        throw PathExplorerError.valueConversionError(value: String(describing: value), type: String(describing: Self.typeDescription))
    }
}

extension String: KeyAllowedType {
    public static let typeDescription = "String"
}

extension Int: KeyAllowedType {
    public static let typeDescription = "Integer"
}

extension Double: KeyAllowedType {
    public static let typeDescription = "Real"
}

extension Bool: KeyAllowedType {
    public static let typeDescription = "Boolean"

    static let trueSet: Set<String> = ["y", "yes", "Y", "Yes", "YES", "t", "true", "T", "True", "TRUE"]
    static let falseSet: Set<String> = ["n", "no", "N", "No", "NO", "f", "false", "F", "False", "FALSE"]
}

extension AnyHashable: KeyAllowedType {
    public static let typeDescription = "Automatic"
}
