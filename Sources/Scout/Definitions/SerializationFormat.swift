//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Format which allows serialization
public protocol SerializationFormat {

    /// Regular expression pattern to find all the scout folded marks in the exported string
    static var foldedRegexPattern: String { get }

    static func serialize(data: Data) throws -> Any
    static func serialize(value: Any) throws -> Data
}

public struct PlistFormat: SerializationFormat {

    public static var foldedRegexPattern: String {
        let foldedMark = PathExplorerSerialization<Self>.foldedMark
        let foldedKey = PathExplorerSerialization<Self>.foldedKey

        return #"(?<=<array>)\s*<string>\#(foldedMark)</string>\s*(?=</array>)"# // array
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

    public static var foldedRegexPattern: String {
        let foldedMark = PathExplorerSerialization<Self>.foldedMark
        let foldedKey = PathExplorerSerialization<Self>.foldedKey

        return #"(?<=\[)\s*"\#(foldedMark)"\s*(?=\])"# // array
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
