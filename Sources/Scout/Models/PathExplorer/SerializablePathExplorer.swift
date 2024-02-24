//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - SerializablePathExplorer

/// A `PathExplorer` which can be instantiated from data and export itself to another format
public protocol SerializablePathExplorer: PathExplorer {

    /// The `DataFormat` of the serializable `PathExplorer`: JSON, Plist, XML, or YAML
    static var format: DataFormat { get }

    /// Initialize a new ``PathExplorer`` from the `Data`
    ///
    /// - Throws: If the data cannot be serialized into the format
    init(data: Data) throws

    /// Export the path explorer value to data
    func exportData() throws -> Data

    /// Export the path explorer value to a String
    ///
    /// - note: The single values will be exported correspondingly to the data format.
    /// For instance: `<string>Hello</string>` and not  `Hello`.
    /// To get only the value of the `PathExplorer` without the format , use `description`
    /// or the corresponding type (e.g. `pathExplorer.int` or `pathExplorer.bool`)
    func exportString() throws -> String

    /// Export the path explorer value to a CSV if possible, using the provided separator.
    ///
    /// - note: Not all values are exportable to CSV. For instance, a three dimensions array is not exportable, neither an array of heterogeneous dictionaries.
    func exportCSV(separator: String?) throws -> String

    /// Export the path explorer value to the specified format data with a default root name "root"
    func exportData(to format: DataFormat, rootName: String?) throws -> Data

    /// Export the path explorer value to the specified format string data with a default root name "root"
    func exportString(to format: DataFormat, rootName: String?) throws -> String

    /// Returns a new explorer from the provided CSV string when it's possible.
    /// - Parameters:
    ///     - string: The CSV as `String`
    ///     - separator: The `Character` used as separator in the CSV string
    ///     - hasHeaders: Specify whether the CSV string has named headers. Named headers can be full ``Path``s to structure the explorer
    ///
    /// - Returns: A `SerializablePathExplorer` from the provided CSV
    /// - Throws: If the CSV cannot be converted to Self
    static func fromCSV(string: String, separator: Character, hasHeaders: Bool) throws -> Self

    /// New explorer replacing the group values (array or dictionaries) sub values by a unique one
    /// holding a fold mark to be replaced when exporting the string value.
    /// - note: Use ``exportFoldedString(upTo:)`` to directly get the string value
    func folded(upTo level: Int) -> Self

    /// Folded explored description, replacing the group values (array or dictionaries) sub values by a single string "..."
    ///
    /// - Important: To be used only for display purpose as the returned string will not have a proper format
    func exportFoldedString(upTo level: Int) throws -> String
}

// MARK: - Constants

extension SerializablePathExplorer {

    var defaultCSVSeparator: String { ";" }
    var nullCSVValue: String { "NULL" }
}

// MARK: - Default implementations

public extension SerializablePathExplorer {

    /// Export the path explorer value to a CSV if possible. Using the default separator ';'
    ///
    /// - note: Not all values are exportable to CSV. For instance, a three dimensions array is not exportable, neither an array of heterogeneous dictionaries.
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
