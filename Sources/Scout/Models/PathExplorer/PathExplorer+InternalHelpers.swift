//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

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

// MARK: - Properties

public extension PathExplorer {

    /// `real` property for convenience naming
    public var double: Double? { real }
}

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

extension PathExplorer {

    /// Compute the index, positive or negative. Negative index uses the array count
    /// - Parameters:
    ///   - index: Index to compute
    ///   - arrayCount: Array count
    ///   - allowNegative: If false, the function will throw if a negative index is passed
    ///   - path: Path to use when throwing an error
    func computeIndex(from index: Int, arrayCount: Int, allowNegative: Bool, in path: Path) throws -> Int {
        let computedIndex = (index < 0 && allowNegative) ? arrayCount + index : index

        guard 0 <= computedIndex, computedIndex < arrayCount else {
            throw PathExplorerError.subscriptWrongIndex(path: path.flattened(), index: index, arrayCount: arrayCount)
        }
        return computedIndex
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

    /// When dealing with setting or deleting operations, this method ensures the given last element is correct
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

    var defaultCSVSeparator: String { ";" }

    /// Export the path explorer value to a CSV if possible. Use the default separator ';' if none specified
    public func exportCSV() throws -> String {
        try exportCSV(separator: nil)
    }

    /// Export the path explorer value to the specified format data
    public func exportData(to format: DataFormat) throws -> Data {
        try exportData(to: format, rootName: nil)
    }

    /// Export the path explorer value to the specified format string data
    public func exportString(to format: DataFormat) throws -> String {
        try exportString(to: format, rootName: nil)
    }
}
