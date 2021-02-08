//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Yams

/// Format which allows serialization
public protocol SerializationFormat {

    /// Regular expression pattern to find all the scout folded marks in the exported string
    static var foldedRegexPattern: String { get }

    /// Identifier of the serialization data format
    static var dataFormat: DataFormat { get }

    static func serialize(data: Data) throws -> Any
    static func serialize(value: Any) throws -> Data
}

extension SerializationFormat {

    static var foldedMark: String { PathExplorerSerialization<Self>.foldedMark }
    static var foldedKey: String { PathExplorerSerialization<Self>.foldedKey }
}

public struct PlistFormat: SerializationFormat {

    public static let dataFormat = DataFormat.plist

    public static var foldedRegexPattern: String {
        #"(?<=<array>)\s*<string>\#(foldedMark)</string>\s*(?=</array>)"# // array
        + #"|(?<=<dict>)\s*<key>\#(foldedKey)</key>\s*<string>\#(foldedMark)</string>\s*(?=</dict>)"# // dict
    }

    public static func serialize(data: Data) throws -> Any {
         try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    }

    public static func serialize(value: Any) throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: .zero)
    }
}

public struct JsonFormat: SerializationFormat {

    public static let dataFormat = DataFormat.json

    public static var foldedRegexPattern: String {
        #"(?<=\[)\s*"\#(foldedMark)"\s*(?=\])"# // array
        + #"|(?<=\{)\s*"\#(foldedKey)"\s*:\s*"\#(foldedMark)"\s*(?=\})"# // dict
    }

    public static func serialize(data: Data) throws -> Any {
         try JSONSerialization.jsonObject(with: data, options: [])
    }

    public static func serialize(value: Any) throws -> Data {
        if #available(OSX 10.15, *) {
            return try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .withoutEscapingSlashes])
        } else {
            return try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted])
        }
    }
}

public struct YamlFormat: SerializationFormat {

    public static let dataFormat = DataFormat.yaml

    public static var foldedRegexPattern: String {
        #"\#(foldedMark)\s*(?=\n)"# // array
        + #"|\#(foldedKey)\s*:\s*\#(foldedMark)\s*(?=\n)"# // dict
    }

    public static func serialize(data: Data) throws -> Any {
        guard
            let string = String(data: data, encoding: .utf8),
            let serialized = try Yams.load(yaml: string)
        else {
            throw PathExplorerError.dataToStringConversionError
        }
        return serialized
    }

    /// Required cast from `Any` to `NodeRepresentable`
    ///
    /// It seems to be a general bug in Swift. When working with an `Any` value from a deserialized data, the
    /// value cannot conform to a protocol if not casted.
    ///
    /// As the YAMS library is casting `Any` as `NodeRepresentable` the problem arises.
    /// - note:
    /// Linked references and issues:
    /// - [Stack Overflow](https://stackoverflow.com/questions/42033735/failing-cast-in-swift-from-any-to-protocol)
    /// - [bugs.Swift](https://bugs.swift.org/browse/SR-3871)
    private static func castToNodeRepresentable(_ value: Any) -> NodeRepresentable {
        if var value = value as? [String: Any] {
            value.forEach { value[$0.key] = castToNodeRepresentable($0.value) }
            return value

        } else if let value = value as? [Any] {
            return value.map(castToNodeRepresentable)

        } else if let value = value as? Int {
            return value as NodeRepresentable

        } else if let value = value as? Double {
            return value as NodeRepresentable

        } else if let value = value as? Date {
            return value as NodeRepresentable

        } else if let value = value as? Bool {
            return value as NodeRepresentable

        } else {
            return String(describing: value) as NodeRepresentable
        }
    }

    public static func serialize(value: Any) throws -> Data {
        let value = castToNodeRepresentable(value)
        let string = try Yams.dump(object: value)

        guard let data = string.data(using: .utf8) else {
            throw PathExplorerError.dataToStringConversionError
        }
        return data
    }
}