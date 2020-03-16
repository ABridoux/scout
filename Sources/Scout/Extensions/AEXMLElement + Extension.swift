import AEXML

extension AEXMLElement {
    var childrenName: String {
        // xml keys have to have a key name. If the key has existing children,
        // we will take the name of the first child. Otherwise we will remove the "s" from the parent key name
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
}
