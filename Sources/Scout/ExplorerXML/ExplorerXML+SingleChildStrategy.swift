//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - SingleChildStrategy

extension ExplorerXML {

    public struct SingleChildStrategy {

        // MARK: Type alias

        public typealias Transform = (_ key: String, _ value: ExplorerValue) -> ExplorerValue

        // MARK: Properties

        var transform: Transform

        // MARK: Init

        init(transform: @escaping Transform) {
            self.transform = transform
        }
    }
}

// MARK: - Static

extension ExplorerXML.SingleChildStrategy {

    public static let dictionary = ExplorerXML.SingleChildStrategy { (key, value) -> ExplorerValue in .dictionary([key: value]) }
    public static let array = ExplorerXML.SingleChildStrategy { (_, value) -> ExplorerValue in .array([value]) }
    public static func custom(_ transform: @escaping Transform) -> ExplorerXML.SingleChildStrategy {
        ExplorerXML.SingleChildStrategy { (key, value) in transform(key, value) }
    }

    /// Check the the element name. With a default name, an array is returned.
    /// Otherwise a dictionary
    public static let `default` = ExplorerXML.SingleChildStrategy { (key, value) in
        if key == ExplorerXML.Element.defaultName {
            return array.transform(key, value)
        } else {
            return dictionary.transform(key, value)
        }
    }
}
