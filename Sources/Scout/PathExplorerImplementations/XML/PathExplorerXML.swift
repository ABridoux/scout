//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

public struct PathExplorerXML: PathExplorer {

    // MARK: - Properties

    var element: AEXMLElement

    public var readingPath = Path()

    // MARK: PathExplorer

    public var string: String? { element.string.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var real: Double? { element.double }

    public func array<Value>(_ type: KeyTypes.Get.ValueType<Value>) -> [Value]? {
        var array = [Value]()
        for child in element.children {
            if let value = type.value(from: child) {
                array.append(value)
            } else {
                // one child value cannot be casted so exit
                return nil
            }
        }

        return array
    }

    public func dictionary<Value>(_ type: KeyTypes.Get.ValueType<Value>) -> [String: Value]? {
        guard element.differentiableChildren else { return nil }

        var dict = [String: Value]()
        for child in element.children {
            if let value = type.value(from: child) {
                dict[child.name] = value
            } else {
                // one child value cannot be casted so exit
                return nil
            }
        }

        return dict
    }

    public var stringValue: String { element.string.trimmingCharacters(in: .whitespacesAndNewlines) }

    public var description: String {
        if element.children.isEmpty, element.attributes.isEmpty, let value = element.value {
            // single value
            return value
        }
        return exportString()
    }

    public var format: DataFormat { .xml }

    /// `true` if the explorer has been folded
    var isFolded = false

    static let foldedRegexPattern = #"(?<=>)\s*<\#(foldedKey)>\#(foldedMark)</\#(foldedKey)>\s*(?=<)"#
}

// MARK: - Initialization

extension PathExplorerXML {

    public init(data: Data) throws {
        let document = try AEXMLDocument(xml: data)
        element = document.root
        readingPath.append(element.name)
    }

    public init(element: AEXMLElement, path: Path = .empty) {
        self.element = element
        readingPath = path
    }

    @available(*, deprecated, message: "Use 'init(element:path)' instead")
    public init(value: Any) {
        element = AEXMLElement(name: "", value: String(describing: value), attributes: [:])
    }

    public init(stringLiteral value: String) {
        self.init(element: AEXMLElement(name: "root", value: value))
    }

    public init(booleanLiteral value: Bool) {
        self.init(element: AEXMLElement(name: "root", value: value.description))
    }

    public init(integerLiteral value: Int) {
        self.init(element: AEXMLElement(name: "root", value: value.description))
    }

    public init(floatLiteral value: Double) {
        self.init(element: AEXMLElement(name: "root", value: value.description))
    }
}

// MARK: - PathExplorer Functions

extension PathExplorerXML {

    // MARK: Get

    public func get(_ path: Path) throws  -> Self {
        var currentPathExplorer = self

        try path.forEach { element in
            currentPathExplorer = try currentPathExplorer.get(element: element)
        }

        return currentPathExplorer
    }

    public func get<T>(_ path: Path, as type: KeyTypes.KeyType<T>) throws -> T where T: KeyAllowedType {
        let explorer = try get(path)

        guard let value = explorer.element.value else {
            throw PathExplorerError.underlyingError("Internal error. No value at '\(path.description)' although the path is valid.")
        }
        return try T(value: value)
    }

    // MARK: Set

    public mutating func set<Type>(_ path: Path, to newValue: Any, as type: KeyTypes.KeyType<Type>) throws where Type: KeyAllowedType {
        try set(path, to: newValue)
    }

    // MARK: Add

    public mutating func add<Type>(_ newValue: Any, at path: Path, as type: KeyTypes.KeyType<Type>) throws where Type: KeyAllowedType {
        try add(newValue, at: path)
    }

    // MARK: Export

    public func exportData() throws -> Data {
        let document = AEXMLDocument(root: element, options: .init())
        let xmlString = document.xml

        guard let data  = xmlString.data(using: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }

        return data
    }

    public func exportString() -> String {
        // when printing out an element which has a parent, the indentation will remain the same
        // which is unwanted so remove the parent by copying the element (parent setter is internal)
        let copy = element.copy()
        copy.addChildren(element.children)
        var description = copy.xml

        if isFolded {
            description = description.replacingOccurrences(of: Self.foldedRegexPattern, with: "...", options: .regularExpression)
        }

        return description
    }

    public mutating func fold(upTo level: Int) {
        guard level >= 0 else {
            if !element.children.isEmpty {
                element.children.forEach { $0.removeFromParent() }
                let foldedElement = AEXMLElement(name: Self.foldedKey, value: Self.foldedMark)
                element.addChild(foldedElement)
            }

            return
        }

        isFolded = true

        for (index, child) in element.children.enumerated() {
            var pathExplorer = PathExplorerXML(element: child, path: readingPath.appending(index))
            pathExplorer.fold(upTo: level - 1)
        }
    }

    // MARK: Conversion

    public func convertValue<Type: KeyAllowedType>(to type: KeyTypes.KeyType<Type>) throws -> Type {
        try Type(value: stringValue)
    }
}

extension PathExplorerXML {
    public var data: Data? {
        Data(base64Encoded: element.string)
    }

    public init(value: ExplorerValue) {
        self.init(element: AEXMLElement(name: "root"))

        element.setup(with: value)
    }

    public func isEqual(to other: PathExplorerXML) -> Bool {
        element.isEqual(to: other.element)
    }

    public func set(_ path: Path, to newValue: ExplorerValue) throws {
    }

    public func set<Type>(_ path: Path, to newValue: ExplorerValue, as type: KeyTypes.KeyType<Type>) throws where Type: KeyAllowedType {

    }
}
