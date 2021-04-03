//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct ValueTypeError: LocalizedError, Equatable {
    public private(set) var path: Path
    let description: String

    public var errorDescription: String? { "[\(path.description)] \(description)" }

    init(path: Path = .empty, description: String) {
        self.path = path
        self.description = description
    }
}

// MARK: - Path building

extension ValueTypeError {

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: Path) -> Self {
        guard self.path.isEmpty else { return self }
        return ValueTypeError(path: path, description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: PathElement...) -> Self {
        guard self.path.isEmpty else { return self }
        return ValueTypeError(path: Path(path), description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: [PathElement]) -> Self {
        guard self.path.isEmpty else { return self }
        return ValueTypeError(path: Path(path), description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: Slice<Path>) -> Self {
        guard self.path.isEmpty else { return self }
        return ValueTypeError(path: Path(path), description: description)
    }

    func adding(_ element: PathElementRepresentable) -> ValueTypeError {
        ValueTypeError(path: path.appending(element), description: description)
    }
}

// MARK: - Registered errors

public extension ValueTypeError {

    static func missing(key: String, bestMatch: String?) -> Self {
        ValueTypeError(description: "Missing key '\(key)' in dictionary. Best match found: '\(bestMatch ?? "none")'")
    }

    static var subscriptKeyNoDict: Self {
        ValueTypeError(description: "The value cannot be subscripted with a string as it is not a dictionary")
    }

    static func wrong(index: Int, arrayCount: Int) -> Self {
        ValueTypeError(description: "Index \(index) out of bounds to subscript the array with \(arrayCount) elements")
    }

    static var subscriptIndexNoArray: Self {
        ValueTypeError(description: "The value cannot be subscripted with an index as it is not an array")
    }

    static func wrongUsage(of element: PathElement) -> Self {
        return ValueTypeError(description: "The element \(element.keyName) \(element) cannot be used here. \(element.usage)")
    }

    static func wrong(bounds: Bounds, arrayCount: Int) -> Self {
        let description =
        """
        Wrong slice '[\(bounds.lowerString):\(bounds.upperString)]' for array with count: \(arrayCount).
        Valid slice: 0 <= lowerBound <= upperBound < arrayCount. Negative bounds are subtracted from the array count (-bound -> arrayCount - bound).
        Omit lower to target first index. Omit upper to target last index.
        """

        return ValueTypeError(description: description)
    }

    static func wrong(regexPattern: String) -> Self {
        ValueTypeError(description: "The string '\(regexPattern)' is not a valid regular expression pattern")
    }
}
