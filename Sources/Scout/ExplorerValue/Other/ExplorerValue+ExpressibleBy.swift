//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - ExpressibleByStringLiteral

extension ExplorerValue: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension ExplorerValue: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self = .int(value)
    }
}

// MARK: - ExpressibleByFloatLiteral

extension ExplorerValue: ExpressibleByFloatLiteral {

    public init(floatLiteral value: Double) {
        self = .double(value)
    }
}

// MARK: - ExpressibleByBooleanLiteral

extension ExplorerValue: ExpressibleByBooleanLiteral {

    public init(booleanLiteral value: Bool) {
        self  = .bool(value)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension ExplorerValue: ExpressibleByArrayLiteral {

    public init(arrayLiteral elements: ExplorerValue...) {
        self = .array(elements)
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension ExplorerValue: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (String, ExplorerValue)...) {
        self = .dictionary(Dictionary(uniqueKeysWithValues: elements))
    }
}
