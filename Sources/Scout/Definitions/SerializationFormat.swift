import Foundation

/// Format which allows serialization
public protocol SerializationFormat {
    static func serialize(data: Data) throws -> Any
    static func serialize(value: Any) throws -> Data
}

public struct PlistFormat: SerializationFormat {
    public static func serialize(data: Data) throws -> Any {
         try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    }

    public static func serialize(value: Any) throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: value, format: .xml, options: .zero)
    }
}

public struct JsonFormat: SerializationFormat {
    public static func serialize(data: Data) throws -> Any {
         try JSONSerialization.jsonObject(with: data, options: [])
    }

    public static func serialize(value: Any) throws -> Data {
        try JSONSerialization.data(withJSONObject: value, options: [])
    }
}
