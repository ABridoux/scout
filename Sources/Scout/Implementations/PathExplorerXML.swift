import Foundation
import AEXML

public struct PathExplorerXML: PathExplorer, CustomStringConvertible {

    // MARK: - Properties

    var element: AEXMLElement

    public var string: String? { element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var real: Double? { element.double }

    public var stringValue: String { element.string }

    public var description: String { element.xml }

    // MARK: - Initialization

    public init(data: Data) throws {
        let document = try AEXMLDocument(xml: data)
        element = document.root
    }

    init(element: AEXMLElement) {
        self.element = element
    }

    public init(value: Any) {
        element = AEXMLElement(name: "", value: String(describing: value), attributes: [:])
    }

    // MARK: - Functions

    // MARK: Public subscripts

    public func get(_ pathElements: Path) throws  -> Self {
        var currentPathExplorer = self

        try pathElements.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        return currentPathExplorer
    }

    public func get(_ pathElements: PathElement...) throws -> Self {
        try get(pathElements)
    }

    public mutating func set(_ path: [PathElement], to newValue: Any) throws  {
        guard let newValueString = newValue as? String else {
            throw PathExplorerError.invalidValue(newValue)
        }

        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        guard currentPathExplorer.element.children.isEmpty else {
            throw PathExplorerError.wrongValueForKey(value: newValueString, element: currentPathExplorer.element.name)
        }

        currentPathExplorer.element.value = newValueString
    }

    public mutating  func set(_ pathElements: PathElement..., to newValue: Any) throws  {
        try set(pathElements, to: newValue)
    }

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        currentPathExplorer.element.name = newKeyName
    }

    public mutating func set(_ pathElements: PathElement..., keyNameTo newKeyName: String) throws {
        try set(pathElements, keyNameTo: newKeyName)
    }

    public mutating func delete(_ path: Path) throws {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(element: $0)
        }

        currentPathExplorer.element.removeFromParent()
    }

    public mutating func delete(_ pathElements: PathElement...) throws {
        try delete(pathElements)
    }

    // MARK: Subscript helpers

    func get(at index: Int) throws -> Self {
        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(index: index, arrayCount: element.children.count)
        }

        return PathExplorerXML(element: element.children[index])
    }

    mutating func set(index: Int, to newValue: Any) throws  {
        guard let newValueString = newValue as? String else {
            throw PathExplorerError.invalidValue(newValue)
        }

        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.arraySubscript(element.xml)
        }

        element.children[index].value = newValueString
    }

    func get(for key: String) throws  -> PathExplorerXML {
        if element.name == key {
            return self
        } else {
            let child = element[key]
            guard child.error == nil else {
                throw PathExplorerError.subscriptMissingKey(key)
            }
            return PathExplorerXML(element: element[key])
        }
    }

    mutating func set(key: String, to newValue: Any) throws {
        guard let newValueString = newValue as? String else {
            throw PathExplorerError.invalidValue(newValue)
        }

        guard element[key].children.isEmpty else {
            throw PathExplorerError.invalidValue(newValue)
        }

        element[key].value = newValueString
    }

    func get(element pathElement: PathElement) throws  -> Self {
        if let stringElement = pathElement as? String {
            return try get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return try get(at: intElement)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
    }

    func delete(element: PathElement) throws {
        
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

    public func exportString() throws -> String {
        AEXMLDocument(root: element, options: .init()).xml
    }
}
