//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension ExplorerXML: SerializablePathExplorer {

    public static var format: DataFormat { .xml }

    public init(data: Data) throws {
        let document = try AEXMLDocument(xml: data)
        self.init(element: document.root)
    }

    /// Export the path explorer value to data
    public func exportData() throws -> Data {
        try description.data(using: .utf8).unwrapOrThrow(.dataToString)
    }

    public func exportString() throws -> String { description }

    public func exportData(to format: DataFormat, rootName: String?) throws -> Data {
        switch format {
        case .json: return try CodableFormats.JsonDefault.encode(explorerValue, rootName: rootName)
        case .plist: return try CodableFormats.PlistDefault.encode(explorerValue, rootName: rootName)
        case .yaml: return try CodableFormats.YamlDefault.encode(explorerValue, rootName: rootName)
        case .xml: return try exportData()
        }
    }

    public func exportString(to format: DataFormat, rootName: String?) throws -> String {
        switch format {
        case .json: return try PathExplorers.Json(value: explorerValue).exportString()
        case .plist: return try PathExplorers.Plist(value: explorerValue).exportString()
        case .yaml: return try PathExplorers.Yaml(value: explorerValue).exportString()
        case .xml: return try exportString()
        }
    }
}
