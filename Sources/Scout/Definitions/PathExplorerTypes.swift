//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public typealias Xml = PathExplorerXML
public typealias Json = PathExplorerSerialization<JsonFormat>
public typealias Plist = PathExplorerSerialization<PlistFormat>
public typealias Yaml = PathExplorerSerialization<YamlFormat>

@available(*, deprecated, message: "'PathExplorerFactory' will be removed in Scout 2.0.0. Use 'PathExplorer(data:)' instead")
public struct PathExplorerFactory {
    public static func make<T: PathExplorer>(_ type: T.Type, from data: Data) throws -> T {
        try T(data: data)
    }
}

/// Unique identifier of a data format
public enum DataFormat: String {
    case json, plist, xml, yaml
}
