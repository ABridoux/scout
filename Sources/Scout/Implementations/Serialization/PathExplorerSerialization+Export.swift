//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerSerialization {

    private var defaultRootName: String { "root" }

    public func exportData() throws -> Data {
        try F.serialize(value: value)
    }

    public func exportString() throws -> String {
        let data = try exportData()

        guard var string = String(data: data, encoding: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        if isFolded {
            string = string.replacingOccurrences(of: F.foldedRegexPattern, with: "...", options: .regularExpression)
        }

        guard format == .json else { return string }

        if #available(OSX 10.15, *) {
            // the without-backslash option is available
            return string
        } else {
            // we have to remvove the back slashes
            return string.replacingOccurrences(of: "\\", with: "")
        }
    }

    public func exportData(to format: DataFormat, rootName: String?) throws -> Data {
        switch format {
        case .json: return try JsonFormat.serialize(value: value)
        case .plist: return try PlistFormat.serialize(value: value)
        case .yaml: return try YamlFormat.serialize(value: value)
        case .xml:
            let element = exportToXML(rootName: rootName)
            guard let data = AEXMLDocument(root: element).xml.data(using: .utf8) else {
                throw PathExplorerError.stringToDataConversionError
            }
            return data
        }
    }

    public func exportString(to format: DataFormat, rootName: String?) throws -> String {
        switch format {
        case .json, .plist, .yaml:
            let data = try exportData(to: format)

            guard let string = String(data: data, encoding: .utf8) else {
                throw PathExplorerError.dataToStringConversionError
            }
            return string

        case .xml:
            let element = exportToXML(rootName: rootName)
            return element.xml
        }
    }

    func exportToXML(rootName: String?) -> AEXMLElement {
        let root = AEXMLElement(name: rootName ?? defaultRootName)
        xmlElement(on: root, for: value)

        if root.children.count == 1 { // dictionary with a single root element
            return root.children[0]
        }
        return root
    }

    func xmlElement(on element: AEXMLElement, for value: Any) {
        switch value {

        case let dict as DictionaryValue:
            let children = dict.map { (key, value) -> AEXMLElement in
                let child = AEXMLElement(name: key)
                xmlElement(on: child, for: value)

                return child
            }
            element.addChildren(children)

        case let array as ArrayValue:
            let children = array.enumerated().map { (index, value) -> AEXMLElement in
                let child = AEXMLElement(name: "\(element.name)-\(index)")
                xmlElement(on: child, for: value)

                return child
            }
            element.addChildren(children)

        default:
            element.value = String(describing: value)
        }
    }
}
