//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

struct JsonColors: Codable {
    var punctuation: Int?
    var keyName: Int?
    var keyValue: Int?
}

struct YamlColors: Codable {
    var punctuation: Int?
    var keyName: Int?
    var keyValue: Int?
}

struct PlistColors: Codable {
    var tag: Int?
    var keyName: Int?
    var keyValue: Int?
    var header: Int?
    var comment: Int?
}

struct XmlColors: Codable {
    var punctuation: Int?
    var openingTag: Int?
    var closingTag: Int?
    var key: Int?
    var header: Int?
    var comment: Int?
}

/// Plist file to specify custom colors
struct ColorFile: Codable {
    var json: JsonColors?
    var yaml: YamlColors?
    var plist: PlistColors?
    var xml: XmlColors?
}
