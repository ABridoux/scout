//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Collection of `PathElement`s to subscript a `PathExplorer`
public struct Path: Equatable {

    // MARK: - Constants

    static let defaultSeparator = "."
    private static let countSymbol = PathElement.defaultCountSymbol
    private static let keysListSymbol = PathElement.defaultKeysListSymbol

    static func splitRegexPattern(separator: String) -> String {
        var regex = #"\(.+\)"# // anything between brackets is allowed
        regex += #"|\[[0-9\#(countSymbol):-]+\]"# // indexes and count
        regex += #"|\{\#(keysListSymbol)\}"# // keys list
        regex += #"|#(\x5C#|[^#])+#"# // dictionary filter
        regex += #"|[^\#(separator)^\[^\]^\{^\}]+"# // standard key

        return regex
    }

    // MARK: - Properties

    private var elements = [PathElement]()

    public static var empty: Path { Path([PathElement]()) }

    // MARK: - Initialization

    /**
     Instantiate a `Path` for a string representing path components separated with the separator.

     ### Example with default separator "."

     `computers[2].name` will make the path `["computers", 2, "name"]`

     `computer.general.serial_number` will make the path `["computer", "general", "serial_number"]`

     `company.computers[#]` will make the path `["company", "computers", PathElement.count]`

     - parameter string: The string representing the path
     - parameter separator: The separator used to split the string. Default is "."

     ### Brackets
     When enclosed with brackets, a path element will not be parsed. For example ```computer.(general.information).serial_number```
     will make the path ["computer", "general.information", "serial_number"]

     ### Excluded separators
     The following separators will not work: "[", "]", "(", ")".
     When using a special caracter with [regular expression](https://developer.apple.com/documentation/foundation/nsregularexpression#1965589),
     it is required to quote it with "\\".
    */
    public init(string: String, separator: String = "\\.") throws {
        var elements = [PathElement]()
        // setup the regular expressions
        let splitRegex = try NSRegularExpression(pattern: Self.splitRegexPattern(separator: separator))

        let matches = splitRegex.matches(in: string)
        for match in matches {

            // remove the brackets if any
            var match = match
            if match.hasPrefix("("), match.hasSuffix(")") {
                match.removeFirst()
                match.removeLast()
            }

            let element = PathElement(from: match)
            elements.append(element)
        }

        self.elements = elements
    }

    public init(_ pathElements: [PathElementRepresentable]) {
        elements = pathElements.map { $0.pathValue }
    }

    public init(_ pathElements: PathElementRepresentable...) {
        elements = pathElements.map { $0.pathValue }
    }

    public init(pathElements: PathElement...) {
        elements = pathElements
    }

    public init( pathElements: [PathElement]) {
        elements = pathElements
    }

    // MARK: - Functions

    // MARK: Path manipulations

    public func appending(_ elements: PathElementRepresentable...) -> Path { Path(self.elements + elements) }
    public func appending(_ elements: PathElement...) -> Path { Path(self.elements + elements) }

    public mutating func removeLast() -> PathElement { elements.removeLast() }
}

extension Path: Collection {

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    /// Last element in the Path
    public var last: PathElement? { elements.last }

    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public subscript(elementIndex: Int) -> PathElement {
        assert(elementIndex >= startIndex && elementIndex <= endIndex)
        return elements[elementIndex]
    }

    public mutating func append(_ element: PathElementRepresentable) {
        elements.append(element.pathValue)
    }

    public mutating func popFirst() -> PathElement? {
        if let firstElement = elements.first {
            elements.removeFirst()
            return firstElement
        }
        return nil
    }

    public mutating func popLast() -> PathElement? {
        if let lastElement = elements.last {
            elements.removeLast()
            return lastElement
        }
        return nil
    }
}

extension Path: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        var description = ""
        elements.forEach { element in
            switch element {
            case .index, .count, .slice, .keysList:
                // remove the point added automatically to a path element
                if description.hasSuffix(Self.defaultSeparator) {
                    description.removeLast()
                }
                description.append(element.description)

            case .filter(let pattern): description.append("#\(pattern)#")
            case .key: description.append(element.description)
            }

            description.append(Self.defaultSeparator)
        }
        // remove the last point if any
        if description.hasSuffix(Self.defaultSeparator) {
            description.removeLast()
        }
        return description
    }

    public var debugDescription: String { description }
}

extension Path: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = PathElementRepresentable

    public init(arrayLiteral elements: PathElementRepresentable...) {
        self.elements = elements.map { $0.pathValue }
    }
}
