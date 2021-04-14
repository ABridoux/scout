//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    static let defaultName = "element"

    static func new(value: ExplorerValue, name: String?) -> AEXMLElement {
        let name = name ?? defaultName

        switch value {
        case .string(let string): return AEXMLElement(name: name, value: string)
        case .int(let int), .count(let int): return AEXMLElement(name: name, value: int.description)
        case .double(let double): return AEXMLElement(name: name, value: double.description)
        case .bool(let bool): return AEXMLElement(name: name, value: bool.description)
        case .data(let data): return AEXMLElement(name: name, value: data.base64EncodedString())

        case .array(let array), .slice(let array):
            let element = AEXMLElement(name: name)
            array.forEach { value in
                element.addChild(new(value: value, name: defaultName))
            }
            return element

        case .dictionary(let dict), .filter(let dict):
            let element = AEXMLElement(name: name)
            dict.forEach { (key, value) in
                let child = new(value: value, name: key)
                element.addChild(child)
            }
            return element

        case .keysList(let keys):
            let element = AEXMLElement(name: name)
            keys.forEach { key in
                element.addChild(name: "key", value: key)
            }
            return element
        }
    }

    /// Complexity: `O(h)`  where `h` is the larger height to last child
    var explorerValue: ExplorerValue {
        if children.isEmpty {
            return singleExplorerValue
        }

        if let names = uniqueChildrenNames, names.count > 1 { // dict
            let dict = children.map { (key: $0.name, value: $0.explorerValue) }
            return .dictionary(Dictionary(uniqueKeysWithValues: dict))
        } else { // array
            return .array(children.map { $0.explorerValue })
        }
    }

    private var singleExplorerValue: ExplorerValue {
        if let int = Int(string) {
            return .int(int)
        } else if let double = Double(string) {
            return .double(double)
        } else if let bool = Bool(string) {
            return .bool(bool)
        } else {
            return .string(string)
        }
    }
}
