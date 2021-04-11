//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

@available(*, deprecated, renamed: "PathExplorers.Xml")
public typealias Xml = PathExplorerXML
@available(*, deprecated, renamed: "PathExplorers.Json")
public typealias Json = PathExplorerSerialization<JsonFormat>
@available(*, deprecated, renamed: "PathExplorers.Plist")
public typealias Plist = PathExplorerSerialization<PlistFormat>

public enum PathExplorers {
    public typealias Xml = PathExplorerXML
    public typealias Json = PathExplorerSerialization<SerializationFormats.Json>
    public typealias Plist = PathExplorerSerialization<SerializationFormats.Plist>
    public typealias Yaml = PathExplorerSerialization<SerializationFormats.Yaml>

    public typealias XmlBis = CodableFormatPathExplorer<CodableFormats.XmlDefault>
    public typealias JsonBis = CodableFormatPathExplorer<CodableFormats.JsonDefault>
    public typealias PlistBis = CodableFormatPathExplorer<CodableFormats.PlistDefault>
    public typealias YamlBis = CodableFormatPathExplorer<CodableFormats.YamlDefault>
}
