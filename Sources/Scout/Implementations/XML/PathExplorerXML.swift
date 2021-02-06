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

    public var stringValue: String { element.string.trimmingCharacters(in: .whitespacesAndNewlines) }

    public var description: String {
        // when priting out an element which has a parent, the identation will remain the same
        // which is unwanted so remove the parent by copying the element (parent setter is internal)
        let copy = element.copy()
        copy.addChildren(element.children)
        var description = copy.xml

        if isFolded {
            description = description.replacingOccurrences(of: Self.foldedRegexPattern, with: "...", options: .regularExpression)
        }

        return description
    }

    public var format: DataFormat { .xml }

    /// `true` if the explorer has been folded
    var isFolded = false

    static let foldedRegexPattern = #"(?<=>)\s*<\#(foldedKey)>\#(foldedMark)</\#(foldedKey)>\s*(?=<)"#

    // MARK: - Initialization

    public init(data: Data) throws {
        let document = try AEXMLDocument(xml: data)
        element = document.root
        readingPath.append(element.name)
    }

    init(element: AEXMLElement, path: Path) {
        self.element = element
        readingPath = path
    }

    public init(value: Any) {
        element = AEXMLElement(name: "", value: String(describing: value), attributes: [:])
    }

    // MARK: - Functions

    // MARK: Get

    public func get(_ path: Path) throws  -> Self {
        var currentPathExplorer = self

        try path.forEach { element in
            currentPathExplorer = try currentPathExplorer.get(element: element)
        }

        return currentPathExplorer
    }

    public func get<T>(_ path: Path, as type: KeyType<T>) throws -> T where T: KeyAllowedType {
        let explorer = try get(path)

        guard let value = explorer.element.value else {
            throw PathExplorerError.underlyingError("Internal error. No value at '\(path.description)' although the path is valid.")
        }
        return try T(value: value)
    }

    // MARK: Set

    public mutating func set<Type>(_ path: Path, to newValue: Any, as type: KeyType<Type>) throws where Type: KeyAllowedType {
        try set(path, to: newValue)
    }

    // MARK: Add

    public mutating func add<Type>(_ newValue: Any, at path: Path, as type: KeyType<Type>) throws where Type: KeyAllowedType {
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

    public func exportString() throws -> String { description }

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

    public func convertValue<Type: KeyAllowedType>(to type: KeyType<Type>) throws -> Type {
        if let value = Type(stringValue) {
            return value
        } else {
            throw PathExplorerError.valueConversionError(value: stringValue, type: String(describing: Type.self))
        }
    }
}
