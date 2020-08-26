//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    /// Copy of the element, without the children
    func copy() -> AEXMLElement { AEXMLElement(name: name, value: value, attributes: attributes) }

    /// xml keys have to have a key name. If the key has existing children,
    /// we will take the name of the first child. Otherwise we will remove the "s" from the parent key name
    var childrenName: String {
        var keyName: String
        if let name = children.first?.name {
            keyName = name
        } else {
            keyName = name
            if keyName.hasSuffix("s") {
                keyName.removeLast()
            }
        }
        return keyName
    }

    /// The common name of all the children is one is found
    /// - note: Handles the case where the name is a pah leading to the key when using dictionary filters
    var commonChildrenName: String? {
        guard
            let firstChild = children.first,
            let name = firstChild.name.components(separatedBy: Path.defaultSeparator).last
        else {
            return nil
        }

        for child in children {
            if child.name.components(separatedBy: ".").last != name {
                return nil
            }
        }

        return name
    }
}
