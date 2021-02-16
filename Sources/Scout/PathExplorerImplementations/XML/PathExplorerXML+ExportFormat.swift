//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

// MARK: - Public

extension PathExplorerXML {

    public func exportData(to format: DataFormat, rootName: String?) throws -> Data {
        let serializeValue = { serialize(element: element) }

        switch format {
        case .xml:
            guard let data = element.xml.data(using: .utf8) else {
                throw PathExplorerError.stringToDataConversionError
            }
            return data

        case .json:
            return try SerializationFormats.Json.serialize(value: serializeValue())
        case .plist:
            return try SerializationFormats.Plist.serialize(value: serializeValue())
        case .yaml:
            return try SerializationFormats.Yaml.serialize(value: serializeValue())
        }
    }

    public func exportString(to format: DataFormat, rootName: String?) throws -> String {

        switch format {
        case .xml:
            return element.xml

        case .json, .plist, .yaml:
            let data = try exportData(to: format)
            guard let string = String(data: data, encoding: .utf8) else {
                throw PathExplorerError.dataToStringConversionError
            }

            return string
        }
    }
}

// MARK: - Internal

extension PathExplorerXML {

    var attributesKey: String { "attributes" }
    var valueKey: String { "value" }

    func serialize(element: AEXMLElement) -> Any {
        if element.children.isEmpty {
            return serializeSingleValue(of: element)
        }

        if element.children.count == 1, let group = element.parent?.bestChildrenGroupFit {
            // one child so it's not possible to decide whether it should be
            // a dictionary or an array. Look at the sibling children to decide
            switch group {
            case .array: return serialiseArrayValue(of: element)
            case .dictionary: return serializeDictionaryValue(of: element)
            }
        }

        if element.commonChildrenName != nil {
            // array since all the keys are the same
            return serialiseArrayValue(of: element)
        } else {
            // dict since there are at least two different keys
            return serializeDictionaryValue(of: element)
        }
    }

    private func serializeSingleValue(of element: AEXMLElement) -> Any {
        let value = element.int ?? element.double ?? element.bool ?? element.string as Any
        if element.attributes.isEmpty {
            return value
        }

        var attributesAndValue = [String: Any]()
        attributesAndValue[attributesKey] = castedAttributes(from: element.attributes)
        attributesAndValue[valueKey] = value

        return attributesAndValue
    }

    private func serializeDictionaryValue(of element: AEXMLElement) -> [String: Any] {
        var childrenDict = [String: Any]()

        var duplicateKeys = [String: Int]()

        element.children.forEach { (child) in
            var key = child.name
            // key renaming in case of a duplicate child name
            if childrenDict.keys.contains(key) {
                duplicateKeys[key, default: 0] += 1
                let count = duplicateKeys[key] !! "The 'duplicateKeys' should have a key '\(key)'"
                key = "\(key)-\(count)"
            }

            childrenDict[key] = serialize(element: child)
        }

        if element.attributes.isEmpty {
            return childrenDict
        } else {
            var dict = [String: Any]()
            dict[attributesKey] = castedAttributes(from: element.attributes)
            dict[valueKey] = childrenDict
            return dict
        }
    }

    private func serialiseArrayValue(of element: AEXMLElement) -> Any {
        var childrenArray = [Any]()

        element.children.forEach { (child) in
            childrenArray.append(serialize(element: child))
        }

        if element.attributes.isEmpty {
            return childrenArray
        } else {
            var dict = [String: Any]()
            dict[attributesKey] = castedAttributes(from: element.attributes)
            dict[valueKey] = childrenArray
            return dict
        }
    }

    private func castedAttributes(from attributes: [StringLiteralType: String]) -> [String: Any] {
        var castedAttributes = [String: Any]()

        attributes.forEach { (key, value) in
            if let int = Int(value) {
                castedAttributes[key] = int
            } else if let double = Double(value) {
                castedAttributes[key] = double
            } else if let bool = Bool(value) {
                castedAttributes[key] = bool
            } else {
                castedAttributes[key] = value
            }
        }

        return castedAttributes
    }
}
