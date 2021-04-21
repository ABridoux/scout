//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension ExplorerXML {

    /// The `ExplorerValue` conversion of the XML element
    ///
    /// - Parameters:
    ///     - keepingAttributes: `true` when the attributes should be included as data
    ///     - singleChildStrategy: Specify how single children should be treated, as they can represent an array or a dictionary.
    /// ### Complexity
    /// `O(n)`  where `n` is the sum of all children
    ///
    /// ### Attributes
    /// If a XML element has attributes and `keepingAttributes` is `true`,
    /// the format of the returned `ExplorerValue` will be modified to
    /// a dictionary with two keys:"attributes" which holds the attributes of the element as `[String: String]`
    /// and "value" which holds the `ExplorerValue` conversion of the element.
    ///
    /// ### Single child strategy
    /// When there is only one child, it's not possible to make sure of the group value that should be create: array or dictionary. The `default` strategy will look at the
    /// child name. If it's the default XML element name, an array will be created. Otherwise, it will be a dictionary. A custom function can be used.
    public func explorerValue(keepingAttributes: Bool = true, singleChildStrategy: SingleChildStrategy = .default) -> ExplorerValue {
        if children.isEmpty {
            return singleExplorerValue(keepingAttributes: keepingAttributes)
        }

        if children.count == 1 {
            let name = children[0].name
            let value = children[0].explorerValue(keepingAttributes: keepingAttributes, singleChildStrategy: singleChildStrategy)
            return singleChildStrategy.transform(name, value)
        }

        if let names = uniqueChildrenNames, names.count > 1 { // dict
            let dict = children.map { (key: $0.name, value: $0.explorerValue(keepingAttributes: keepingAttributes, singleChildStrategy: singleChildStrategy)) }
            let dictValue = ExplorerValue.dictionary(Dictionary(uniqueKeysWithValues: dict))
            return keepingAttributes ? valueWithAttributes(value: dictValue) : dictValue
        } else { // array

            let arrayValue = ExplorerValue.array(children.map { $0.explorerValue(keepingAttributes: keepingAttributes, singleChildStrategy: singleChildStrategy) })
            return keepingAttributes ? valueWithAttributes(value: arrayValue) : arrayValue
        }
    }

    private func singleExplorerValue(keepingAttributes: Bool) -> ExplorerValue {
        let value: ExplorerValue
        if let int = self.int {
            value = .int(int)
        } else if let double = self.double {
            value = .double(double)
        } else if let bool = self.bool {
            value = .bool(bool)
        } else {
            value = .string(self.string ?? "")
        }

        return keepingAttributes ? valueWithAttributes(value: value) : value
    }

    private func valueWithAttributes(value: ExplorerValue) -> ExplorerValue {
        if attributes.isEmpty {
            return value
        } else {
            return .dictionary(["attributes": attributes.explorerValue(), "value": value])
        }
    }

    public struct SingleChildStrategy {
        public typealias Transform = (_ key: String, _ value: ExplorerValue) -> ExplorerValue
        var transform: Transform

        init(transform: @escaping Transform) {
            self.transform = transform
        }

        public static let dictionary = SingleChildStrategy { (key, value) -> ExplorerValue in .dictionary([key: value]) }
        public static let array = SingleChildStrategy { (_, value) -> ExplorerValue in .array([value]) }
        public static func custom(_ transform: @escaping Transform) -> SingleChildStrategy {
            SingleChildStrategy { (key, value) in transform(key, value) }
        }

        public static let `default` = SingleChildStrategy { (key, value) in
            if key == Element.defaultName {
                return array.transform(key, value)
            } else {
                return dictionary.transform(key, value)
            }
        }
    }
}
