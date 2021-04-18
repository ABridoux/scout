//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension CodablePathExplorer: SerializablePathExplorer {

    public static var format: DataFormat { Format.dataFormat }

    public init(data: Data) throws {
        let value = try Format.decode(ExplorerValue.self, from: data)
        self.init(value: value)
    }

    public func exportData() throws -> Data {
        try Format.encode(value)
    }

    public func exportString() throws -> String {
        try String(data: exportData(), encoding: .utf8)
            .unwrapOrThrow(.dataToString)
    }

    public func exportData(to format: DataFormat, rootName: String?) throws -> Data {
        switch format {
        case .json: return try CodableFormats.JsonDefault.encode(value)
        case .plist: return try CodableFormats.PlistDefault.encode(value)
        case .yaml: return try CodableFormats.YamlDefault.encode(value)
        case .xml: return try ExplorerXML(value: value, name: rootName).exportData()
        }
    }

    public func exportString(to format: DataFormat, rootName: String?) throws -> String {
        switch format {
        case .json, .plist, .yaml:
            return try String(data: exportData(to: format, rootName: rootName), encoding: .utf8).unwrapOrThrow(.dataToString)

        case .xml: return try ExplorerXML(value: value, name: rootName).exportString()
        }
    }

    public func exportCSV(separator: String?) throws -> String {
        try value.exportCSV(separator: separator ?? defaultCSVSeparator)
    }

    public func folded(upTo level: Int) -> Self {
        Self(value: value.folded(upTo: level))
    }

    public func exportFoldedString(upTo level: Int) throws -> String {
        try folded(upTo: level)
            .exportString()
            .replacingOccurrences(of: Format.foldedRegexPattern, with: "...", options: .regularExpression)
    }
}
