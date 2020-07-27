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

    /// Placed after an array or dictionary to return the array count
    case count

    // -- Symbols
    static let defaultCountSymbol = "#"

    // MARK: - Properties

    var key: String? {
        if case let .key(key) = self {
            return key
        } else {
            return nil
        }
    }

    var index: Int? {
        if case let .index(index) = self {
            return index
        } else {
            return nil
        }
    }

    /// Can subscript an array
    public var isArraySubscripter: Bool {
        switch self {
        case .count, .index: return true
        default: return false
        }
    }

    // MARK: - Initialization

    init(from string: String) {
        if let index = Int(string) {
            self = .index(index)
        } else if string == Self.defaultCountSymbol {
            self = .count
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
        }
    }
}
