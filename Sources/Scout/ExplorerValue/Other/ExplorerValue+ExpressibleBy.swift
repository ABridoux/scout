//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension ExplorerValue: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension ExplorerValue: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

extension ExplorerValue: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

extension ExplorerValue: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self  = .bool(value)
    }
}

extension ExplorerValue: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: ExplorerValue...) {
        self = .array(elements)
    }
}

extension ExplorerValue: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, ExplorerValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}
