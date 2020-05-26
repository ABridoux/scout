import Foundation
import AEXML

public struct PathExplorerXML {

    // MARK: - Properties

    var element: AEXMLElement

    public var readingPath = Path()

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

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(at index: Int, negativeIndexEnabled: Bool = false) throws -> Self {

        if negativeIndexEnabled, index == -1 {
            guard let last = element.children.last else {
                throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
            }

            return PathExplorerXML(element: last, path: readingPath.appending(index))
        }

        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.subscriptWrongIndex(path: readingPath, index: index, arrayCount: element.children.count)
        }

        return PathExplorerXML(element: element.children[index], path: readingPath.appending(index))
    }

    func get(for key: String) throws  -> PathExplorerXML {
        if element.name == key {
            return self
        } else {
            let child = element[key]
            guard child.error == nil else {
                throw PathExplorerError.subscriptMissingKey(path: readingPath, key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(element.children.map { $0.name })))
            }
            return PathExplorerXML(element: element[key], path: readingPath.appending(key))
        }
    }

    /// - parameter negativeIndexEnabled: If set to `true`, it is possible to get the last element of an array with the index `-1`
    func get(pathElement: PathElement, negativeIndexEnabled: Bool = true) throws  -> Self {
        if let stringElement = pathElement as? String {
            return try get(for: stringElement)
        } else if let intElement = pathElement as? Int {
            return try get(at: intElement, negativeIndexEnabled: negativeIndexEnabled)
        } else {
            // prevent a new type other than int or string to conform to PathElement
            assertionFailure("Only Int and String can be PathElement")
            return self
        }
    }

    // MARK: Set

    mutating func set(index: Int, to newValue: String) throws {
        guard element.children.count > index, index >= 0 else {
            throw PathExplorerError.arraySubscript(readingPath)
        }

        element.children[index].value = newValue
    }

    mutating func set(key: String, to newValue: String) throws {

        guard element[key].children.isEmpty else {
            throw PathExplorerError.invalidValue(newValue)
        }

        element[key].value = newValue
    }

    public mutating func set(_ path: [PathElement], to newValue: Any) throws {
        let newValueString = try convert(newValue, to: .string)

        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(pathElement: $0)
        }

        guard currentPathExplorer.element.children.isEmpty else {
            throw PathExplorerError.wrongValueForKey(value: newValueString, element: currentPathExplorer.element.name)
        }

        currentPathExplorer.element.value = newValueString
    }

    // -- Set key name

    public mutating func set(_ path: Path, keyNameTo newKeyName: String) throws {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(pathElement: $0)
        }

        currentPathExplorer.element.name = newKeyName
    }

    // MARK: Delete

    public mutating func delete(_ path: Path) throws {
        var currentPathExplorer = self

        try path.forEach {
            currentPathExplorer = try currentPathExplorer.get(pathElement: $0)
        }

        currentPathExplorer.element.removeFromParent()
    }

    public mutating func delete(_ pathElements: PathElement...) throws {
        try delete(pathElements)
    }

    // MARK: Add

    public mutating func add(_ newValue: Any, at path: Path) throws {
        guard !path.isEmpty else { return }

        let newValue = try convert(newValue, to: .string)

        var path = path
        let lastElement = path.removeLast()
        var currentPathExplorer = self

        try path.forEach { element in
            if let pathExplorer = try? currentPathExplorer.get(pathElement: element, negativeIndexEnabled: false) {
                // the key exist. Just keep parsing
                currentPathExplorer = pathExplorer
            } else {
                // the key does not exist. Add a new key to it
                let keyName = element as? String ?? currentPathExplorer.element.childrenName
                currentPathExplorer.element.addChild(name: keyName, value: nil, attributes: [:])

                if let index = element as? Int, index == -1 {
                    // get the last element
                    let childrenCount = currentPathExplorer.element.children.count - 1
                    currentPathExplorer = try currentPathExplorer.get(pathElement: childrenCount)
                } else {
                    currentPathExplorer = try currentPathExplorer.get(pathElement: element)
                }
            }
        }

        try currentPathExplorer.add(newValue, for: lastElement)

    }

    public mutating func add(_ newValue: Any, at pathElements: PathElement...) throws {
        try add(newValue, at: pathElements)
    }

    /// Add the new value to the array or dictionary value
    /// - Parameters:
    ///   - newValue: The new value to add
    ///   - element: If string, try to add the new value to the dictionary. If int, try to add the new value to the array. `-1` will add the value at the end of the array.
    /// - Throws: if self cannot be subscript with the given element
    mutating func add(_ newValue: String, for pathElement: PathElement) throws {

        if let key = pathElement as? String {
            if let existingChild = element.firstDescendant(where: { $0.name == key }) {
                // set the value of the child if one exists with the given key
                existingChild.value = newValue
            } else {
                // otherwise add the child
                element.addChild(name: key, value: newValue, attributes: [:])
            }
        } else if let index = pathElement as? Int {
            let keyName = element.childrenName

            if index == -1 || element.children.isEmpty {
                element.addChild(name: keyName, value: newValue, attributes: [:])
            } else if index >= 0, element.children.count > index {
                // we have to copy the element as we cannot modify its children
                let copy = AEXMLElement(name: element.name, value: element.value, attributes: element.attributes)
                for childIndex in 0...element.children.count {
                    switch childIndex {
                    case 0..<index:
                        copy.addChild(element.children[childIndex])
                    case index:
                        copy.addChild(name: keyName, value: newValue, attributes: [:])
                    case index+1...element.children.count:
                        copy.addChild(element.children[childIndex - 1])
                    default: break
                    }
                }
                if let parent = element.parent {
                    // replace the element in the hierarchy if necessary
                    element.removeFromParent()
                    parent.addChild(copy)
                } else {
                    // the element is the root element, so simply change it
                    element = copy
                }
            } else {
                throw PathExplorerError.wrongValueForKey(value: newValue, element: index)
            }
        }
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
