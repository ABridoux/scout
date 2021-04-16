//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    static var defaultArrayElementName: String { "element" }

    static func newChildElement(value: String) -> AEXMLElement {
        AEXMLElement(name: defaultArrayElementName, value: value)
    }

    /// Copy of the element, without the children
    func copyFlat() -> AEXMLElement { AEXMLElement(name: name, value: value, attributes: attributes) }

    /// Name of the first child if one exists. Otherwise the parent key name will be used.
    var childrenName: String { children.first?.name ?? name }

    /// The common name of all the children if one is found
    /// - note: Handles the case where the name is a path leading to the key when using dictionary filters
    var commonChildrenName: String? {
        guard
            let firstChild = children.first,
            let name = firstChild.name.components(separatedBy: ExplorerXML.GroupSample.keySeparator).last
        else {
            return nil
        }

        for child in children {
            if child.name.components(separatedBy: ExplorerXML.GroupSample.keySeparator).last != name {
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

    /// All children names. `nil` if two names are reused
    var uniqueChildrenNames: Set<String>? {
        var names = Set<String>()

        for child in children {
            if names.contains(child.name), names.count > 1 {
                return nil
            }
            names.insert(child.name)
        }

        return names
    }

    func getJaroWinkler(key: String) throws -> AEXMLElement {
        return try children
            .first { $0.name == key }
            .unwrapOrThrow(
                .missing(
                    key: key,
                    bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(children.map(\.name)))
                )
            )
    }

}
