//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension PathExplorerSerialization {

    public func exportTo(_ format: DataFormat) throws -> Data {
        switch format {
        case .json: return try JsonFormat.serialize(value: value)
        case .plist: return try PlistFormat.serialize(value: value)
        case .yaml: return try YamlFormat.serialize(value: value)
        case .xml: return try exportToXML()
        }
    }

    func exportToXML() throws -> Data {
        let root = AEXMLElement(name: "root")
        xmlElement(on: root)

        guard let data = AEXMLDocument(root: root).xml.data(using: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        return data
    }

    func xmlElement(on element: AEXMLElement) {
        switch value {

        case let dict as DictionaryValue:
            let children = dict.map { (key, value) -> AEXMLElement in
                let child = AEXMLElement(name: key)
                let pathExplorer = PathExplorerSerialization(value: value)
                pathExplorer.xmlElement(on: child)

                return child
            }
            element.addChildren(children)

        case let array as ArrayValue:
            let children = array.map { value  -> AEXMLElement in
                let child = AEXMLElement(name: element.name)
                let pathExplorer = PathExplorerSerialization(value: value)
                pathExplorer.xmlElement(on: child)

                return child
            }
            element.addChildren(children)

        default:
            element.value = String(describing: value)
        }
    }
}
