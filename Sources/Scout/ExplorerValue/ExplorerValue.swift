//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// The values a `PathExplorer` can take
public enum ExplorerValue {

    // single
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case data(Data)
    case date(Date)

    // group
    case array(ArrayValue)
    case dictionary(DictionaryValue)
}

// MARK: - Type aliases

extension ExplorerValue {

    public typealias ArrayValue = [ExplorerValue]
    public typealias DictionaryValue = [String: ExplorerValue]
    typealias SlicePath = Slice<Path>
}

// MARK: - Hashable

extension ExplorerValue: Hashable {}

// MARK: - Special init

extension ExplorerValue {

    init(value: Any) throws {
        if let int = value as? Int {
            self = .int(int)
        } else if let double = value as? Double {
            self = .double(double)
        } else if let string = value as? String {
            self = .string(string)
        } else if let bool = value as? Bool {
            self = .bool(bool)
        } else if let data = value as? Data {
            self = .data(data)
        } else if let date = value as? Date {
            self = .date(date)
        } else if let dict = value as? [String: Any] {
            self = try .dictionary(dict.mapValues { try ExplorerValue(value: $0) })
        } else if let array = value as? [Any] {
            self = try .array(array.map { try ExplorerValue(value: $0) })
        } else {
            throw ExplorerError.invalid(value: value)
        }
    }

    static func singleFrom(string: String) -> ExplorerValue {
        if let int = Int(string) {
            return .int(int)
        } else if let double = Double(string) {
            return .double(double)
        } else if let bool = Bool(string) {
            return .bool(bool)
        } else {
            return .string(string)
        }
    }
}
