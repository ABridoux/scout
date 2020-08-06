//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

// MARK: - Literal type extensions

extension PathExplorer {
    public init(stringLiteral value: Self.StringLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer {
    public init(booleanLiteral value: Self.BooleanLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer {
    public init(integerLiteral value: Self.IntegerLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer {
    public init(floatLiteral value: Self.FloatLiteralType) {
        self.init(value: value)
    }
}

// MARK: Data validation

extension PathExplorer {

    /// Ensure a value as a correct type
    /// - Parameter value: The value to convert
    /// - Parameter type: The type to use to convert the value. Use `automatic` to let the function try the available types
    /// - Throws: PathExplorerError.valueConversionError when the value is not convertible to the type or  to be automatically converted
    /// - Returns: The value converted to the optimal type
    func convert<Type: KeyAllowedType>(_ value: Any, to type: KeyType<Type>) throws -> Type {

        if !(type is AutomaticType) {
            // avoid to try to infer the type if it's specified
            return try Type(value: value)
        }

        // try to infer the type

        // handle the case when value is a string
        if let stringValue = (value as? CustomStringConvertible)?.description {
            if let bool = Bool(stringValue) {
                return try Type(value: bool)
            } else if let int = Int(stringValue) {
                return try Type(value: int)
            } else if let double = Double(stringValue) {
                return try Type(value: double)
            } else {
                return try Type(value: stringValue)
            }
        }

        // otherwise, try to return the type as it is
        return try Type(value: value)
    }

    /// When dealing with setting, deleting or adding operations, this method ensures the given last element is correct
    /// - Parameters:
    ///   - element: Last element of the path
    ///   - path: Path where the element is
    /// - Throws: If element cannot be used as the last element
    func validateLast(element: PathElement?, in path: Path) throws {
        if element == .count {
            throw PathExplorerError.countWrongUsage(path: path)
        }
    }
}
