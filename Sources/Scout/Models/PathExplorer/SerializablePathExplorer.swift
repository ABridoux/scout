//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public protocol SerializablePathExplorer: PathExplorerBis {

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

    /// Replace the group values (array or dictionaries) sub values by a unique one
    /// holding a fold mark to be replaced when exporting the string
    mutating func fold(upTo level: Int)
}

public extension SerializablePathExplorer {

    var defaultCSVSeparator: String { ";" }

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