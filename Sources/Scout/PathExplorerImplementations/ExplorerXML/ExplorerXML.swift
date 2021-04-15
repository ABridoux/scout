//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

public struct ExplorerXML: PathExplorerBis {

    // MARK: - Constants

    typealias SlicePath = Slice<Path>
    public typealias Element = AEXMLElement

    // MARK: - Properties

    private let element: AEXMLElement

    var name: String { element.name }

    public var string: String? { element.string.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var real: Double? { element.double }

    var valueAsAny: Any { int ?? real ?? bool ?? string ?? "" }

    /// Complexity: `O(h)`  where `h` is the larger height to last child
    var explorerValue: ExplorerValue {
        if children.isEmpty {
            return singleExplorerValue
        }

        if let names = element.uniqueChildrenNames, names.count > 1 { // dict
            let dict = children.map { (key: $0.name, value: $0.explorerValue) }
            return .dictionary(Dictionary(uniqueKeysWithValues: dict))
        } else { // array
            return .array(children.map { $0.explorerValue })
        }
    }

    private var singleExplorerValue: ExplorerValue {
        if let int = Int(element.string) {
            return .int(int)
        } else if let double = Double(element.string) {
            return .double(double)
        } else if let bool = Bool(element.string) {
            return .bool(bool)
        } else {
            return .string(element.string)
        }
    }

    /// Always `nil` on XML
    public var data: Data? { nil }

    public func array<T>(of type: T.Type) throws -> [T] where T: ExplorerValueCreatable {
        try children.map { try T(from: $0.explorerValue) }
    }

    public func dictionary<T>(of type: T.Type) throws -> [String: T] where T: ExplorerValueCreatable {
        try Dictionary(uniqueKeysWithValues: children.map { try ($0.name, T(from: $0.explorerValue)) })
    }

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

    var xml: String { element.xml }

    // MARK: - Initialization

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
        case .int(let int), .count(let int): self.init(name: name, value: int.description)
        case .double(let double): self.init(name: name, value: double.description)
        case .bool(let bool): self.init(name: name, value: bool.description)
        case .data(let data): self.init(name: name, value: data.base64EncodedString())

        case .keysList(let keys):
            let element = Element(name: name)
            self.init(element: element)
            keys.forEach { (key) in
                let explorer = ExplorerXML(name: "key", value: key)
                addChild(explorer)
            }

        case .array(let array), .slice(let array):
            let element = Element(name: name)
            if case .slice = value {
                self.init(element: element)
            } else {
                self.init(element: element)
            }
            array.forEach { (value) in
                let explorer = ExplorerXML(value: value, name: nil)
                addChild(explorer)
            }

        case .dictionary(let dict), .filter(let dict):
            let element = Element(name: name)
            if case .filter = value {
                self.init(element: element)
            } else {
                self.init(element: element)
            }
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

    // MARK: - Functions

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

    func with(name: String) -> Self {
        element.name = name
        return ExplorerXML(element: element)
    }

    func set(name: String) {
        element.name = name
    }

    func set(value: String) {
        element.value = value
    }

    func set(value: ValueSetter) {
        switch value {
        case .explorerValue(let value): set(newValue: value)
        case .xmlElement(let element): set(newElement: element)
        }
    }

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
        case .int(let int), .count(let int): set(value: int.description)
        case .double(let double): set(value: double.description)
        case .bool(let bool): set(value: bool.description)
        case .data(let data): set(value: data.base64EncodedString())

        case .keysList(let keys):
            removeChildrenFromParent()
            let newChildren = keys.map { ExplorerXML(name: "key", value: $0) }
            addChildren(newChildren)

        case .array(let array), .slice(let array):
            removeChildrenFromParent()
            addChildren(array.map(ExplorerXML.init))

        case .dictionary(let dict), .filter(let dict):
            removeChildrenFromParent()
            let newChildren = dict.map { ExplorerXML(value: $0.value).with(name: $0.key) }
            addChildren(newChildren)
        }
    }
}

extension ExplorerXML {

    /// A new `ExplorerXML` with a new element and new children, keeping the name, value and attributes
    func copy() -> Self {
        ExplorerXML(element: element.copy())
    }
}

extension ExplorerXML {

    enum GroupSample {
        case filter, slice
    }
}

extension ExplorerXML {

    enum ValueSetter {
        case explorerValue(ExplorerValue)
        case xmlElement(Element)
    }
}

extension ExplorerXML: EquatablePathExplorer {
    func isEqual(to other: ExplorerXML) -> Bool {
        element.isEqual(to: other.element)
    }
}
