struct JsonColors: Codable {
    var punctuation: Int? = nil
    var keyName: Int? = nil
    var keyValue: Int? = nil
}

struct PlistColors: Codable {
    var tag: Int? = nil
    var keyName: Int? = nil
    var keyValue: Int? = nil
    var header: Int? = nil
    var comment: Int? = nil
}

struct XmlColors: Codable {
    var punctuation: Int? = nil
    var openingTag: Int? = nil
    var closingTag: Int? = nil
    var key: Int? = nil
    var header: Int? = nil
    var comment: Int? = nil
}

/// Plist file to specify custom colors
struct ColorFile: Codable {
    var json: JsonColors? = nil
    var plist: PlistColors? = nil
    var xml: XmlColors? = nil
}
