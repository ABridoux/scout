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
