//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    /// Copy of the element, without the children
    func copy() -> AEXMLElement { AEXMLElement(name: name, value: value, attributes: attributes) }

    /// Name of the first child if one exists. Otherwise the parent key name will be used.
    var childrenName: String { children.first?.name ?? name }

    /// The common name of all the children is one is found
    /// - note: Handles the case where the name is a path leading to the key when using dictionary filters
    var commonChildrenName: String? {
        guard
            let firstChild = children.first,
            let name = firstChild.name.components(separatedBy: GroupSample.keySeparator).last
        else {
            return nil
        }

        for child in children {
            if child.name.components(separatedBy: GroupSample.keySeparator).last != name {
                return nil
            }
        }

        return name
    }

    /// `true` if all the children have a different name
    var differentiableChildren: Bool {
        var names = Set<String>()

        for child in children {
            if names.contains(child.name) {
                return false
            }
            names.insert(child.name)
        }

        return true
    }
}
