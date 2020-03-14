import Foundation
import AEXML

public struct PathExplorerXML: PathExplorer, CustomStringConvertible {

    // MARK: - Properties

    var element: AEXMLElement

    public var string: String? { element.string }
    public var bool: Bool? { element.bool }
    public var int: Int? { element.int }
    public var real: Double? { element.double }
    public var date: Date? { nil }

    public var description: String { element.xml }

    // MARK: - Initialization

    public init(data: Data) throws {
        let document = try AEXMLDocument(xml: data)
        element = document.root
    }

    public init(string: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw PathExplorerError.stringToDataConversionError
        }
        try self.init(data: data)
    }

    init(element: AEXMLElement) {
        self.element = element
    }

    public init(value: Any) {
        element = AEXMLElement(name: "", value: String(describing: value), attributes: [:])
    }

    // MARK: - Functions

    // MARK: Subscript

    public subscript(key: String) -> PathExplorerXML {
        get { get(for: key) }
        set { set(newValue, for: key)}
    }

    public subscript(index: Int) -> PathExplorerXML {
        get { get(at: index) }
        set { set(newValue, at: index) }
    }

    public subscript(path: PathElement...) -> PathExplorerXML {
        get { get(at: path) }
        set { set(newValue, at: path) }
    }

    public subscript(path: Path) -> PathExplorerXML {
        get { get(at: path) }
        set { set(newValue, at: path) }
    }

    // MARK: Subscript helpers

    private func get(at index: Int) -> PathExplorerXML {
        guard
            element.children.count > index,
            index >= 0
        else {
            return self
        }
        return PathExplorerXML(element: element.children[index])
    }

    private func set(_ newValue: PathExplorerXML, for key: String) {
        element[key].value = newValue.string
    }

    private func get(for key: String) -> PathExplorerXML {
        if element.name == key {
            return self
        } else {
            return PathExplorerXML(element: element[key])
        }
    }

    private func set(_ newValue: PathExplorerXML, at index: Int) {
        guard
            element.children.count > index,
            index >= 0
        else {
            return
        }

        element.children[index].value = newValue.string
    }

    private func get(forElement pathElement: PathElement) -> PathExplorerXML {
        if let stringElement = pathElement as? String {
            return get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return get(at: intElement)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
    }

    private func get(at pathElements: Path) -> PathExplorerXML {
        var currentPathExplorer = self

        pathElements.forEach {
            currentPathExplorer = currentPathExplorer.get(forElement: $0)
        }

        return currentPathExplorer
    }

    private func set(_ newValue: PathExplorerXML, at pathElements: [PathElement]) {
        var currentPathExplorer = self

        pathElements.forEach {
            currentPathExplorer = currentPathExplorer.get(forElement: $0)
        }

        currentPathExplorer.element.value = newValue.element.value
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

    public func outputString() throws -> String? {
        let document = AEXMLDocument(root: element, options: .init())
        return document.xml
    }
}
