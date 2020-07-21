import Foundation

/// Store the possible elements that can be used to subscript a `PathExplorer`
public enum PathElement: Equatable {
    case key(String)
    case index(Int)

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
