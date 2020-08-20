//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Array of `PathElementRepresentable` to find a specific value in a `PathExplorer`
public struct Path: Equatable {

    // MARK: - Constants

    let defaultSeparator = "."

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

     - note: When enclosed with brackets, a path element will not be parsed. For example ```computer.(general.information).serial_number```
     will make the path ["computer", "general.information", "serial_number"]

     - note: The following separators will not work: "[", "]", "(", ")".
     When using a special caracter with [regular expression](https://developer.apple.com/documentation/foundation/nsregularexpression#1965589),
     it is required to quote it with "\\".
    */
    public init(string: String, separator: String = "\\.") throws {
        var elements = [PathElement]()

        let splitRegexPattern = #"\(.+\)|#(\x5C#|[^#])+#|[^\#(separator)]+"#
        let groupSubscripterRegexPattern = #"(?<=\[)[0-9\#(PathElement.defaultCountSymbol):-]+(?=\])"#
        let squareBracketPattern = #"\[|\]"#
        let splitRegex = try NSRegularExpression(pattern: splitRegexPattern)
        let groupSubscripterRegex = try NSRegularExpression(pattern: groupSubscripterRegexPattern)
        let squareBracketRegex = try NSRegularExpression(pattern: squareBracketPattern)

        let matches = splitRegex.matches(in: string)
        for match in matches {

            // remove the brackets if any
            var match = match
            if match.hasPrefix("("), match.hasSuffix(")") {
                match.removeFirst()
                match.removeLast()
            }
            let indexMatches = groupSubscripterRegex.matches(in: match, options: [], range: match.nsRange)

            // try to get the group subscripters if any
            if let indexesMatch = try Self.extractGroupSubscripters(in: indexMatches, from: match) {
                elements.append(contentsOf: indexesMatch)
            } else {
                if squareBracketRegex.firstMatch(in: match, range: match.nsRange) != nil {
                    throw PathExplorerError.invalidPathElement(match.pathValue)
                }
                elements.append(match.pathValue)
            }
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

    // MARK: Initialization helpers

    /// Extract group subscripters [] in an element
    /// - Parameters:
    ///   - indexMatches: Results of a `NSRegularExpression` where the pattern [] is found
    ///   - match: The match from which to extract the subscripters
    /// - Throws: If a found subscripter is invalid
    /// - Returns: The associated `PathElement`s of the subscripters
    static func extractGroupSubscripters(in indexMatches: [NSTextCheckingResult], from match: String) throws -> [PathElement]? {
        var indexMatches = indexMatches
        var elements = [PathElement]()

        guard let indexMatch = indexMatches.first else { // we have a first index, so retrieve it and the array name if possible
            return nil
        }

        // get the first element
        let firstElement = PathElement(from: String(match[indexMatch.range]))

        guard firstElement.isGroupSubscripter else {
            throw PathExplorerError.invalidPathElement(match.pathValue)
        }

        if indexMatch.range.lowerBound == 1 {
            // specific case: the root element is an array: there is no array name
            elements.append(firstElement)
        } else {
            // get the array name
            let arrayName = String(match[0..<indexMatch.range.lowerBound - 1])

            elements.append(arrayName.pathValue)
            elements.append(firstElement)
        }

        // now retrieve the remaining indexes
        indexMatches.removeFirst()

        try indexMatches.forEach { indexMatch in
            let element = PathElement(from: String(match[indexMatch.range]))

            guard element.isGroupSubscripter else { throw PathExplorerError.invalidPathElement(match.pathValue) }
            elements.append(element)
        }

        return elements
    }

    // MARK: Path manipulations

    public func appending(_ elements: PathElementRepresentable...) -> Path { Path(self.elements + elements) }
    public func appending(_ elements: PathElement...) -> Path { Path(self.elements + elements) }

    public mutating func removeLast() -> PathElement { elements.removeLast() }

    /// Remove the `.slice` path elements in the array while incrementing the indexes if necessary. Useful when printing the array description in an error.
    func removingSlicings() -> Self {
        var lastLowerBound: Int?
        var newPath = Path()
        for element in self {
            switch element {
            case .slice(let bounds):
                lastLowerBound = bounds.lower
            case .index(let index):
                newPath.append(index + (lastLowerBound ?? 0))
                lastLowerBound = nil
            default: newPath.append(element)
            }
        }

        return newPath
    }
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
            case .index, .count, .slice:
                // remove the point added automatically to a path element
                if description.hasSuffix(defaultSeparator) {
                    description.removeLast()
                }
                description.append(element.description)

            case .filter(let pattern): description.append("#\(pattern)#")
            case .key: description.append(element.description)
            }

            description.append(defaultSeparator)
        }
        // remove the last point if any
        if description.hasSuffix(defaultSeparator) {
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
