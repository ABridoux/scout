//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    func setup(with valueType: ExplorerValue) {
        switch valueType {
        case .int(let int), .count(let int): value = String(int)
        case .double(let double): value = String(double)
        case .string(let string): value = string
        case .bool(let bool): value = String(bool)
        case .data(let data): value = data.base64EncodedString()
        case .keysList(let keys):
            keys.forEach { (key) in addChild(.newChildElement(value: key)) }

        case .array(let array), .slice(let array):
            array.forEach { (element) in
                let child = AEXMLElement(name: Self.defaultArrayElementName)
                child.setup(with: element)
                addChild(child)
            }
        case .dictionary(let dict), .filter(let dict):
            dict.forEach { (key, value) in
                let child = AEXMLElement(name: key)
                child.setup(with: value)
                addChild(child)
            }
        }
    }

    /// Returns a new element with new children, keeping the name, value and attributes
    func copy() -> AEXMLElement {
        let newElement = AEXMLElement(name: name, value: value, attributes: attributes)
        if children.isEmpty {
            return newElement
        }

        children.forEach { newElement.addChild($0.copyFlat()) }
        return newElement
    }
}
