//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - PathElement

/// The possible elements that can be used to subscript a ``PathExplorer``
public enum PathElement: Hashable {

    // MARK: Constants

    // -- Cases
    case key(String)
    case index(Int)

    /// Placed after an array or dictionary to return its count
    case count

    /// Placed after a dictionary to returns its keys as an array
    case keysList

    /// Placed after an array to slice it with a `Bounds` value
    case slice(Bounds)

    /// Regular expression pattern placed after a dictionary to filter the keys
    case filter(String)

    // -- Symbols
    static let defaultCountSymbol = "#"
    static let defaultKeysListSymbol = "#"
}

// MARK: - Computed

extension PathElement {

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

    var usage: String {
        switch self {
        case .key: return "A key subscript a dictionary and is specified with a dot '.' then the key name like 'dictionary.keyName'"
        case .index: return "An index subscript an array and is specified as an integer enclosed with square brackets like '[1]'"
        case .count: return "A count element is specified as a sharp sign enclosed with square brackets '[#]'. It should be the last path element after an array or a dictionary."
        case .keysList: return "A keys list element is specified as a sharp sign enclosed by curl brackets '{#}'. It is placed after a dictionary to get its keys as an array"
        case .slice: return "A slice is specified after an array with lower and upper bounds. It is enclosed by square brackets and the bounds are specified separated by ':' like '[lower:upper]'"
        case .filter: return "A filter is a regular expression placed after a dictionary to filter the keys to target. It is enclosed by sharp signs like '#[a-zA-Z]*#'"
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension PathElement: ExpressibleByStringLiteral {

    // MARK: Type alias

    public typealias StringLiteralType = String

    // MARK: Init

    public init(stringLiteral: String) {
        self = .key(stringLiteral)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension PathElement: ExpressibleByIntegerLiteral {

    // MARK: Type alias

    public typealias IntegerLiteralType = Int

    // MARK: Init

    public init(integerLiteral: Int) {
        self = .index(integerLiteral)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension PathElement: CustomStringConvertible {

    public var description: String {
        switch self {
        case .key(let key): return key
        case .index(let index): return "[\(index)]"
        case .count: return "[\(Self.defaultCountSymbol)]"
        case .keysList: return "{\(Self.defaultKeysListSymbol)}"
        case .slice(let bounds):
            let lowerBound = bounds.lowerString
            let upperBound = bounds.upperString
            return "[\(lowerBound):\(upperBound)]"

        case .filter(let filter):
            return "#\(filter)#"
        }
    }

    var kindDescription: String {
        switch self {
        case .key: return "key"
        case .index: return "index"
        case .count: return "count"
        case .keysList: return "keysList"
        case .slice: return "slice"
        case .filter: return "filter"
        }
    }
}
