//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import AEXML

// MARK: - ExplorerXML

public struct ExplorerXML: PathExplorer {

    // MARK: Constants

    typealias SlicePath = Slice<Path>
    public typealias Element = AEXMLElement

    // MARK: Properties

    /// `var` requirement to test reference
    private var element: AEXMLElement

    // MARK: Computed

    var name: String { element.name }
    var xml: String { element.xml }
    var attributes: [String: String] { element.attributes }
    func attribute(named name: String) -> String? { element.attributes[name] }

    public var string: String? { element.string.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var double: Double? { element.double }
    
    /// XML `date` element is always `nil`
    ///
    /// Date types are not natively supported by XML
    public var date: Date? { nil }

    @available(*, deprecated, renamed: "double")
    public var real: Double? { element.double }

    /// Always `nil` on XML
    public var data: Data? { nil }

    public var isGroup: Bool { !element.children.isEmpty }
    public var isSingle: Bool { element.children.isEmpty }

    public var description: String {
        if element.children.isEmpty, element.attributes.isEmpty, let value = element.value {
            // single value
            return value
        }

        return element.xmlSpaces
    }

    public var debugDescription: String { description }

    // MARK: Initialization

    init(element: Element) {
        self.element = element
    }

    init(name: String, value: String? = nil) {
        self.init(element: Element(name: name, value: value))
    }

    public init(value: ExplorerValue, name: String?) {
        let name = name ?? Element.defaultName

        switch value {
        case .string(let string): self.init(name: name, value: string)
        case .int(let int): self.init(name: name, value: int.description)
        case .double(let double): self.init(name: name, value: double.description)
        case .bool(let bool): self.init(name: name, value: bool.description)
        case .data(let data): self.init(name: name, value: data.base64EncodedString())
        case .date(let date): self.init(name: name, value: date.description)

        case .array(let array):
            let element = Element(name: name)
            self.init(element: element)
            array.forEach { (value) in
                let explorer = ExplorerXML(value: value, name: nil)
                addChild(explorer)
            }

        case .dictionary(let dict):
            let element = Element(name: name)
            self.init(element: element)
            dict.forEach { (key, value) in
                let explorer = ExplorerXML(value: value, name: key)
                addChild(explorer)
            }
        }
    }

    public init(stringLiteral value: String) {
        element = Element(name: Element.defaultName, value: value)
    }

    public init(booleanLiteral value: Bool) {
        element = Element(name: Element.defaultName, value: value.description)
    }

    public init(integerLiteral value: Int) {
        element = Element(name: Element.defaultName, value: value.description)
    }

    public init(floatLiteral value: Double) {
        element = Element(name: Element.defaultName, value: value.description)
    }
}

// MARK: - Collection tranform

extension ExplorerXML {

    public func array<T>(of type: T.Type) throws -> [T] where T: ExplorerValueCreatable {
        try array(of: T.self, keepingAttributes: true, singleChildStrategy: .default)
    }

    /// An array of the provided type.
    ///
    /// - Parameters:
    ///     - keepingAttributes: `true` when the attributes should be included as data
    ///     - singleChildStrategy: Specify how single children should be treated, as they can represent an array or a dictionary.
    ///
    /// ### Attributes
    /// If a XML element has attributes and `keepingAttributes` is `true`,
    /// the format of the returned `ExplorerValue` will be modified to
    /// a dictionary with two keys:"attributes" which holds the attributes of the element as `[String: String]`
    /// and "value" which holds the `ExplorerValue` conversion of the element.
    ///
    /// ### Single child strategy
    /// When there is only one child, it's not possible to make sure of the group value that should be created: array or dictionary.
    /// The `default` strategy will look at the child name. If it's the default XML element name, an array will be created.
    /// Otherwise, it will be a dictionary. A custom function can be used.
    public func array<T: ExplorerValueCreatable>(
        of type: T.Type,
        keepingAttributes: Bool,
        singleChildStrategy: SingleChildStrategy)
    throws -> [T] {
        try children.map { try T(from: $0.explorerValue(keepingAttributes: keepingAttributes, singleChildStrategy: singleChildStrategy)) }
    }

    public func dictionary<T>(of type: T.Type) throws -> [String: T] where T: ExplorerValueCreatable {
        try dictionary(of: T.self, keepingAttributes: true, singleChildStrategy: .default)
    }

    /// A dictionary of the provided type.
    ///
    /// - Parameters:
    ///     - keepingAttributes: `true` when the attributes should be included as data
    ///     - singleChildStrategy: Specify how single children should be treated, as they can represent an array or a dictionary.
    ///
    /// ### Attributes
    /// If a XML element has attributes and `keepingAttributes` is `true`,
    /// the format of the returned `ExplorerValue` will be modified to
    /// a dictionary with two keys:"attributes" which holds the attributes of the element as `[String: String]`
    /// and "value" which holds the `ExplorerValue` conversion of the element.
    ///
    /// ### Single child strategy
    /// When there is only one child, it's not possible to make sure of the group value that should be created: array or dictionary.
    /// The `default` strategy will look at the child name. If it's the default XML element name, an array will be created.
    /// Otherwise, it will be a dictionary. A custom function can be used.
    public func dictionary<T: ExplorerValueCreatable>(
        of type: T.Type,
        keepingAttributes: Bool,
        singleChildStrategy: SingleChildStrategy)
    throws -> [String: T] {
        let dict = try children.map { try ($0.name, T(from: $0.explorerValue(keepingAttributes: keepingAttributes, singleChildStrategy: singleChildStrategy))) }
        return Dictionary(uniqueKeysWithValues: dict)
    }
}

// MARK: - Children

extension ExplorerXML {

    func addChild(_ explorer: ExplorerXML) {
        element.addChild(explorer.element)
    }

    func addChildren(_ children: [ExplorerXML]) {
        element.addChildren(children.map(\.element))
    }

    func removeFromParent() {
        element.removeFromParent()
    }

    func removeChildrenFromParent() {
        element.children.forEach { $0.removeFromParent() }
    }

    var childrenCount: Int { element.children.count }

    /// Name of the first child if one exists. Otherwise the parent key name will be used.
    var childrenName: String { element.childrenName }

    /// `true` if all the children have a different name
    var differentiableChildren: Bool { element.differentiableChildren }

    /// `true` if all children have the same name
    var childrenHaveCommonName: Bool { element.commonChildrenName != nil }

    /// All children names. `nil` if two names are reused
    var uniqueChildrenNames: Set<String>? { element.uniqueChildrenNames }

    var children: [ExplorerXML] {
        get { element.children.map { ExplorerXML(element: $0) }}
        set {
            element.children.forEach { $0.removeFromParent() }
            newValue.forEach { element.addChild($0.element) }
        }
    }

    func getJaroWinkler(key: String) throws -> Self {
        try ExplorerXML(element: element.getJaroWinkler(key: key))
    }

    func copyWithoutChildren() -> Self {
        ExplorerXML(name: element.name, value: element.string)
    }

    func copyMappingChildren(_ transform: (ExplorerXML) throws -> ExplorerXML) rethrows -> ExplorerXML {
        let copy = copyWithoutChildren()
        try children.forEach { child in try copy.addChild(transform(child)) }
        return copy
    }
}

// MARK: - Reference

extension ExplorerXML {

    /// `true` if the reference of `element` is shared. Used for copy on write.
    /// - note: Marked `mutating` but does not mutate. Requirement for `isKnownUniquelyReferenced`
    mutating func referenceIsShared() -> Bool { !isKnownUniquelyReferenced(&element) }
}

// MARK: - Setters

extension ExplorerXML {

    func with(name: String) -> Self {
        element.name = name
        return ExplorerXML(element: element)
    }

    func set(name: String) {
        element.name = name
    }

    func set(attributes: [String: String]) {
        element.attributes = attributes
    }

    func with(attributes: [String: String]) -> Self {
        element.attributes = attributes
        return self
    }

    func set(value: String?) {
        element.value = value
    }

    func set(value: ValueSetter) {
        switch value {
        case .explorerValue(let value): set(newValue: value)
        case .explorerXML(let explorer): set(newElement: explorer.element)
        }
    }

    /// Set a new element while trying to keep the name, value and attributes
    private func set(newElement: Element) {
        element.name = newElement.name
        element.value = newElement.value
        element.attributes = newElement.attributes
        element.children.forEach { $0.removeFromParent() }
        newElement.children.forEach { element.addChild($0) }
    }

    private func set(newValue: ExplorerValue) {
        switch newValue {
        case .string(let string): set(value: string)
        case .int(let int): set(value: int.description)
        case .double(let double): set(value: double.description)
        case .bool(let bool): set(value: bool.description)
        case .data(let data): set(value: data.base64EncodedString())
        case .date(let date): set(value: date.description)

        case .array(let array):
            removeChildrenFromParent()
            addChildren(array.map(ExplorerXML.init))

        case .dictionary(let dict):
            removeChildrenFromParent()
            let newChildren = dict.map { ExplorerXML(value: $0.value).with(name: $0.key) }
            addChildren(newChildren)
        }
    }
}

// MARK: - Copy

extension ExplorerXML {

    /// A new `ExplorerXML` with a new element and new children, keeping the name, value and attributes
    func copy() -> Self {
        ExplorerXML(element: element.copy())
    }
}

extension ExplorerXML: EquatablePathExplorer {

    func isEqual(to other: ExplorerXML) -> Bool {
        element.isEqual(to: other.element)
    }
}
