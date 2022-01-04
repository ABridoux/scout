//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension ExplorerXML {

    /// The `ExplorerValue` conversion of the XML element
    ///
    /// - Parameters:
    ///     - attributesStrategy: Specify how attributes should be handled
    ///     - singleChildStrategy: Specify how single children should be treated, as they can represent an array or a dictionary.
    ///
    /// ### Complexity
    /// `O(n)` where `n` is the sum of all children
    public func explorerValue(attributesStrategy: AttributesStrategy, singleChildStrategy: SingleChildStrategy = .default) -> ExplorerValue {
        if children.isEmpty {
            return singleExplorerValue(attributesStrategy: attributesStrategy)
        }

        if children.count == 1 {
            let name = children[0].name
            let value = children[0].explorerValue(attributesStrategy: attributesStrategy, singleChildStrategy: singleChildStrategy)
            return singleChildStrategy.transform(name, value)
        }

        if let names = uniqueChildrenNames, names.count > 1 { // dict
            let dict = children.map { (key: $0.name, value: $0.explorerValue(attributesStrategy: attributesStrategy, singleChildStrategy: singleChildStrategy)) }
            let dictValue = ExplorerValue.dictionary(Dictionary(uniqueKeysWithValues: dict))
            return attributesStrategy.transform(attributes, name, dictValue)

        } else { // array

            let arrayValue = ExplorerValue.array(children.map { $0.explorerValue(attributesStrategy: attributesStrategy, singleChildStrategy: singleChildStrategy) })
            return attributesStrategy.transform(attributes, name, arrayValue)
        }
    }

    private func singleExplorerValue(attributesStrategy: AttributesStrategy) -> ExplorerValue {
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

        return attributesStrategy.transform(attributes, name, value)
    }
}

// MARK: - AttributesStrategy

extension ExplorerXML {

    public struct AttributesStrategy {

        public typealias Transform = (_ attributes: [String: String], _ key: String, _ value: ExplorerValue) -> ExplorerValue
        let transform: Transform

        public init(transform: @escaping Transform) {
            self.transform = transform
        }
    }
}

extension ExplorerXML.AttributesStrategy {

    /// Ignore the attributes during the ``ExplorerValue`` conversion
    public static let ignore = Self { _, _, value in value }

    /// If attributes are not empty, the value will be split in a dictionary with an "attributes" and "value" keys.
    ///
    /// "attributes" is of type `[String: String]` and `value` is the value
    public static let split = Self { attributes, _, value in
        if attributes.isEmpty {
            return value
        } else {
            return .dictionary(["attributes": attributes.explorerValue(), "value": value])
        }
    }

    /// Scout will try to merge the attributes with the elements.
    ///
    /// ### Behavior
    /// - When there are no children, the result is a dictionary with the attributes and the child.
    /// - When the children are a dictionary, both dictionaries will be merged, using the `duplicateStrategy` when there are duplicate keys
    ///  - When the children are an array, the result will be a dictionary holding the attributes and an "elements" key associated to the children array
    ///
    ///  - parameter duplicatesStrategy: When the children are a dictionary, both dictionaries will be merged,
    ///   using the `duplicateStrategy` when there are duplicate keys
    public static func merge(duplicatesStrategy: MergeDuplicatesStrategy) -> Self {
        Self { attributes, key, value in
           guard !attributes.isEmpty else { return value }

           let mappedAttributes = attributes.mapValues(ExplorerValue.singleFrom)
           switch value {
           case .string, .int, .double, .bool, .date, .data:
               return .dictionary([key: value].merging(mappedAttributes, uniquingKeysWith: duplicatesStrategy.transform))

           case let .dictionary(dict):
               return .dictionary(dict.merging(mappedAttributes, uniquingKeysWith: duplicatesStrategy.transform))

           case .array:
               return .dictionary(mappedAttributes.merging([ExplorerXML.Element.arrayDefaultName: value], uniquingKeysWith: duplicatesStrategy.transform))
           }
        }
    }
}

extension ExplorerXML.AttributesStrategy {

    /// A strategy to decide which value to keep when duplicate keys are present during a ``ExplorerXML/AttributesStrategy/merge(duplicatesStrategy:)`` strategy
    public struct MergeDuplicatesStrategy {
        public typealias Transform = (_ attribute: ExplorerValue, _ element: ExplorerValue) -> ExplorerValue

        let transform: Transform

        public init(transform: @escaping Transform) {
            self.transform = transform
        }
    }
}

extension ExplorerXML.AttributesStrategy.MergeDuplicatesStrategy {

    /// In case of a duplicate when merging the attributes and the element, the attribute will be kept and the element discarded
    public static let attribute = Self { attribute, _ in attribute }

    /// In case of a duplicate when merging the attributes and the element, the element will be kept and the attribute discarded
    public static let element = Self { _, element in element }

}

// MARK: - SingleChildStrategy

extension ExplorerXML {

    /// When there is only one child, it's not possible to make sure of the group value that should be created: array or dictionary.
    /// The `default` strategy will look at the child name. If it's the default XML element name, an array will be created.
    /// Otherwise, it will be a dictionary. A custom strategy can be used with ``SingleChildStrategy/init(transform:)``
    public struct SingleChildStrategy {
        public typealias Transform = (_ key: String, _ value: ExplorerValue) -> ExplorerValue
        let transform: Transform

        public init(transform: @escaping Transform) {
            self.transform = transform
        }
    }
}

extension ExplorerXML.SingleChildStrategy {

    public static let dictionary = Self { (key, value) -> ExplorerValue in .dictionary([key: value]) }
    public static let array = Self { (_, value) -> ExplorerValue in .array([value]) }

    /// Check the the element name. With a default name, an array is returned.
    /// Otherwise a dictionary
    public static let `default` = Self { (key, value) in
        if key == ExplorerXML.Element.singleDefaultName {
            return array.transform(key, value)
        } else {
            return dictionary.transform(key, value)
        }
    }
}

// MARK: - Deprecated

extension ExplorerXML {

    @available(*, deprecated, message: "Use ExplorerXML.explorerValue(attributesStrategy:singleChildStrategy:) instead")
    public func explorerValue(keepingAttributes: Bool = true, singleChildStrategy: SingleChildStrategy = .default) -> ExplorerValue {
        explorerValue(attributesStrategy: keepingAttributes ? .split : .ignore, singleChildStrategy: singleChildStrategy)
    }
}

extension ExplorerXML.SingleChildStrategy {

    @available(*, deprecated, message: "Use ExplorerXML.SingleChildStrategy.init(transform:) instead")
    public static func custom(_ transform: @escaping Transform) -> Self {
        Self { (key, value) in transform(key, value) }
    }
}
