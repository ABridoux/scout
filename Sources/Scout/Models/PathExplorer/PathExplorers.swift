//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

/// Namespace to find all PathExplorers in a single place
public enum PathExplorers {

    public typealias Json = CodablePathExplorer<CodableFormats.JsonDefault>
    public typealias Plist = CodablePathExplorer<CodableFormats.PlistDefault>
    public typealias Yaml = CodablePathExplorer<CodableFormats.YamlDefault>
    public typealias Xml = ExplorerXML
}
