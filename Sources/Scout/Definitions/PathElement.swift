//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Store the possible elements that can be used to subscript a `PathExplorer`
public enum PathElement: Equatable {

    // MARK: - Constants

    // -- Cases
    case key(String)
    case index(Int)

    /// Placed after an array or dictionary to return its count
    case count

    /// Placed after an array to slice it with a `Bounds` value
    case slice(Bounds)

    /// Regular expression pattern placed after a dictionary to filter the keys
    case filter(String)

    // -- Symbols
    static let defaultCountSymbol = "#"

    // MARK: - Properties

    /// String value if self is a `key`
    var key: String? {
        if case let .key(key) = self {
            return key
        } else {
            return nil
        }
    }

    /// Int value if self is an `index`
    var index: Int? {
        if case let .index(index) = self {
            return index
        } else {
            return nil
        }
    }

    /// Can subscript an array or a dictionay
    public var isGroupSubscripter: Bool {
        switch self {
        case .count, .index, .slice, .filter: return true
        case .key: return false
        }
    }

    public var usage: String {
        switch self {
        case .key: return "A key subscript a dictionary and is specified with a dot '.' then the key name like 'dictionary.keyName'"
        case .index: return "An index subscript an array and is specified as an integer enclosed with square brackets like '[1]'"
        case .count: return "A count element is specified as a sharp sign enclosed with square brackets '[#]'. It should be the last path element after an array or a dictionary."
        case .slice: return "A slice is specified after an array with lower and upper bounds. It is enclosed by square brackets and the bounds are specified separated by ':' like '[lower:upper]'"
        case .filter: return "A filter is a regular expression placed after a dictionary to filter the keys to target. It is enclosed by sharp signs like '#[a-zA-Z]*#'"
        }
    }

    // MARK: - Initialization

    init(from string: String) {
        if let index = Int(string) {
            self = .index(index)
        } else if string == Self.defaultCountSymbol {
            self = .count
        } else if let range = string.slice {
            self = range
        } else if let filter = string.filter {
            self = filter
        } else {
            self = .key(string)
        }
    }
}

extension PathElement: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String

    public init(stringLiteral: String) {
        self = .key(stringLiteral)
    }
}

extension PathElement: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int

    public init(integerLiteral: Int) {
        self = .index(integerLiteral)
    }
}

extension PathElement: CustomStringConvertible {

    public var description: String {
        switch self {
        case .key(let key): return key
        case .index(let index): return "[\(index)]"
        case .count: return "[\(Self.defaultCountSymbol)]"
        case .slice(let bounds):
            let lowerBound = bounds.lowerString
            let upperBound = bounds.upperString
            return "[\(lowerBound):\(upperBound)]"

        case .filter(let filter):
            return "#\(filter)#"
        }
    }
}
