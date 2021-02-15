//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorer {
    public init(stringLiteral value: Self.StringLiteralType) {
        self.init(value: value)
    }

    public init(booleanLiteral value: Self.BooleanLiteralType) {
        self.init(value: value)
    }

    public init(integerLiteral value: Self.IntegerLiteralType) {
        self.init(value: value)
    }

    public init(floatLiteral value: Self.FloatLiteralType) {
        self.init(value: value)
    }
}
