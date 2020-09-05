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

// MARK: Properties

extension PathExplorer {

    /// The last array slice or dictionary filter found in the path if any
    var lastGroupSample: GroupSample? {
        var lastGroupElement: GroupSample?

        readingPath.forEach { element in
            switch element {
            case .slice(let bounds): lastGroupElement = .arraySlice(bounds)
            case .filter(let pattern): lastGroupElement = .dictionaryFilter(pattern)
            default: break
            }
        }

        return lastGroupElement
    }

    /// Use to name the single key when folding a dictionary
    static var foldedKey: String { "Folded" }

    /// Use to replace the content of a dicionary or array when folding it
    static var foldedMark: String { "~~SCOUT_FOLDED~~" }
}

// MARK: Helpers

public extension PathExplorer {

    /// Delete the key at the given path, specified as array.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: Path) throws {
        try delete(path, deleteIfEmpty: false)
    }

    /// Delete the key at the given path, specified as array.
    /// - Throws: If the path is invalid (e.g. a key does not exist in a dictionary, or indicating an index on a non-array key)
    mutating func delete(_ path: PathElementRepresentable) throws {
        try delete(path, deleteIfEmpty: false)
    }
}

// MARK: Debug

public extension PathExplorer {
    var debugDescription: String { description }
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
            throw PathExplorerError.wrongUsage(of: .count, in: path)
        }
    }
}

// MARK: Export

extension PathExplorer {
    public func exportCSV() throws -> String {
        try exportCSV(separator: ";")
    }
}
