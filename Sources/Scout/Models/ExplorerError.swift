//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public struct ExplorerError: LocalizedError, Equatable {
    public private(set) var path: Path
    let description: String

    public var errorDescription: String? { "'\(path.description)' \(description)" }

    init(path: Path = .empty, description: String) {
        self.path = path
        self.description = description
    }
}

// MARK: - Path building

extension ExplorerError {

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: Path) -> Self {
        guard self.path.isEmpty else { return self }
        return ExplorerError(path: path, description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: PathElement...) -> Self {
        guard self.path.isEmpty else { return self }
        return ExplorerError(path: Path(path), description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: [PathElement]) -> Self {
        guard self.path.isEmpty else { return self }
        return ExplorerError(path: Path(path), description: description)
    }

    /// Return a new `ValueTypeError` with the provided path, only when the current path is not empty.
    /// If the current path is not empty, self is returned
    func with(path: Slice<Path>) -> Self {
        guard self.path.isEmpty else { return self }
        return ExplorerError(path: Path(path), description: description)
    }

    func adding(_ element: PathElementRepresentable) -> ExplorerError {
        ExplorerError(path: path.appending(element), description: description)
    }
}

// MARK: - Registered errors

public extension ExplorerError {

    static func invalid(value: Any) -> Self {
        ExplorerError(description: "The value \(value) is not convertible to ExplorerValue")
    }

    static func missing(key: String, bestMatch: String?) -> Self {
        ExplorerError(description: "Missing key '\(key)' in dictionary. Best match found: '\(bestMatch ?? "none")'")
    }

    static var subscriptKeyNoDict: Self {
        ExplorerError(description: "The value cannot be subscripted with a string as it is not a dictionary")
    }

    static func wrong(index: Int, arrayCount: Int) -> Self {
        ExplorerError(description: "Index \(index) out of bounds to subscript the array with \(arrayCount) elements")
    }

    static var subscriptIndexNoArray: Self {
        ExplorerError(description: "The value cannot be subscripted with an index as it is not an array")
    }

    static func wrongUsage(of element: PathElement) -> Self {
        return ExplorerError(description: "The element \(element.keyName) \(element) cannot be used here. \(element.usage)")
    }

    static func wrong(bounds: Bounds, arrayCount: Int) -> Self {
        let description =
        """
        Wrong slice '[\(bounds.lowerString):\(bounds.upperString)]' for array with count: \(arrayCount).
        Valid slice: 0 <= lowerBound <= upperBound < arrayCount. Negative bounds are subtracted from the array count (-bound -> arrayCount - bound).
        Omit lower to target first index. Omit upper to target last index.
        """

        return ExplorerError(description: description)
    }

    static func wrong(regexPattern: String) -> Self {
        ExplorerError(description: "The string '\(regexPattern)' is not a valid regular expression pattern")
    }

    static func mismatchingType<T>(_ type: T.Type, value: ExplorerValue) -> Self {
        ExplorerError(description: "ExplorerValue \(value) cannot be represented as \(T.self)")
    }

    static func predicateNotEvaluatable(_ predicate: String, description: String) -> Self {
        ExplorerError(description: #"Unable to evaluate the predicate "\#(predicate)". \#(description)"#)
    }
}
