//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Scalar

extension ExplorerValue {

    public var int: Int? {
        switch self {
        case .int(let int): return int
        default: return nil
        }
    }

    public var double: Double? {
        guard case let .double(double) = self else { return nil }
        return double
    }

    @available(*, deprecated, renamed: "double")
    public var real: Double? { double }

    public var string: String? {
        guard case let .string(string) = self else { return nil }
        return string
    }

    public var bool: Bool? {
        guard case let .bool(bool) = self else { return nil }
        return bool
    }

    public var data: Data? {
        guard case let .data(data) = self else { return nil }
        return data
    }

    public var date: Date? {
        guard case let .date(date) = self else { return nil }
        return date
    }
}

// MARK: - Collection

extension ExplorerValue {

    public var array: ArrayValue? {
        switch self {
        case .array(let array): return array
        default: return nil
        }
    }

    public var dictionary: DictionaryValue? {
        switch self {
        case .dictionary(let dict): return dict
        default: return nil
        }
    }

    public func array<T: ExplorerValueCreatable>(of type: T.Type) throws -> [T] {
        let array = try self.array.unwrapOrThrow(.mismatchingType(ArrayValue.self, value: self))
        return try array.map { try T(from: $0) }
    }

    public func dictionary<T: ExplorerValueCreatable>(of type: T.Type) throws -> [String: T] {
        let dict = try dictionary.unwrapOrThrow(.mismatchingType(DictionaryValue.self, value: self))
        return try dict.mapValues { try T(from: $0) }
    }

    func array(_ value: ArrayValue) -> Self { .array(value) }
    func dictionary(_ value: DictionaryValue) -> Self { .dictionary(value) }
}

// MARK: - Group

extension ExplorerValue {

    public var isSingle: Bool { !isGroup }

    public var isGroup: Bool {
        switch self {
        case .array, .dictionary: return true
        default: return false
        }
    }

    var isDictionary: Bool {
        guard case .dictionary = self else { return false }
        return true
    }

    var isArray: Bool {
        guard case .array = self else { return false }
        return true
    }

    var isEmpty: Bool {
        switch self {
        case .array(let array): return array.isEmpty
        case .dictionary(let dict): return dict.isEmpty
        default:
            return false
        }
    }

    var isNull: Bool {
        if case let .string(string) = self, string == "null" {
            return true
        }
        return false
    }
}
