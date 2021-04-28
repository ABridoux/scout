//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// A `PathExplorer` which can be instantiated from data and export itself to another format
public protocol SerializablePathExplorer: PathExplorer {

    static var format: DataFormat { get }

    init(data: Data) throws

    /// Export the path explorer value to data
    func exportData() throws -> Data

    /// Export the path explorer value to a String
    ///
    /// - note: The single values will be exported correspondingly to the data format.
    /// For instance: `<string>Hello</string>` and not ust `Hello`.
    /// To get only the value of the `PathExplorer` without the data , use `description`
    /// or the corresponding type (e.g. `pathExplorer.int` or `pathExplorer.bool`)
    func exportString() throws -> String

    /// Export the path explorer value to a CSV if possible. Use the default separator ';' if none specified
    func exportCSV(separator: String?) throws -> String

    /// Export the path explorer value to the specified format data with a default root name "root"
    func exportData(to format: DataFormat, rootName: String?) throws -> Data

    /// Export the path explorer value to the specified format string data with a default root name "root"
    func exportString(to format: DataFormat, rootName: String?) throws -> String

    /// Returns a new explorer from the provided CSV string when it's possible. Throws otherwise.
    static func fromCSV(string: String, separator: Character, hasHeaders: Bool) throws -> Self

    /// New explorer replacing the group values (array or dictionaries) sub values by a unique one
    /// holding a fold mark to be replaced when exporting the string value.
    /// - note: Use `exportFoldedString(upTo:)` to directly get the string value
    func folded(upTo level: Int) -> Self

    /// Folded explored description, replacing the group values (array or dictionaries) sub values by a single string "..."
    func exportFoldedString(upTo level: Int) throws -> String
}

public extension SerializablePathExplorer {

    var defaultCSVSeparator: String { ";" }
    var nullCSVValue: String { "NULL" }

    /// Export the path explorer value to a CSV if possible. Use the default separator ';' if none specified
    func exportCSV() throws -> String {
        try exportCSV(separator: nil)
    }

    /// Export the path explorer value to the specified format data
    func exportData(to format: DataFormat) throws -> Data {
        try exportData(to: format, rootName: nil)
    }

    /// Export the path explorer value to the specified format string data
    func exportString(to format: DataFormat) throws -> String {
        try exportString(to: format, rootName: nil)
    }
}
