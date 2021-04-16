//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum PathExplorers {

    public typealias Json = CodableFormatPathExplorer<CodableFormats.JsonDefault>
    public typealias Plist = CodableFormatPathExplorer<CodableFormats.PlistDefault>
    public typealias Yaml = CodableFormatPathExplorer<CodableFormats.YamlDefault>
    public typealias Xml = ExplorerXML
}
