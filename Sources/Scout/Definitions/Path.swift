import Foundation

/// Array of `PathElementRepresentable` to find a specific value in a `PathExplorer`
//public typealias Path = [PathElementRepresentable]

public struct Path: Equatable {

    // MARK: - Properties

    private var elements = [PathElement]()

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }
    public var last: PathElement? { elements.last }

    public static var empty: Path { Path([PathElement]()) }

    // MARK: - Initialization

    /**
     Instantiate a `Path` for a string representing path components separated with the separator.

     ### Example with default separator "."

     ```computers[2].name``` will make the path ["computers", 2, "name"]
     ```computer.general.serial_number``` will make the path ["computer", "general", "serial_number"]

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

        let splitRegexPattern = #"\(.+\)|[^\#(separator)]+"#
        let indexRegexPattern = #"(?<=\[)[0-9-]+(?=\])"#
        let squareBracketPattern = #"\[|\]"#
        let splitRegex = try NSRegularExpression(pattern: splitRegexPattern)
        let indexRegex = try NSRegularExpression(pattern: indexRegexPattern)
        let squareBracketRegex = try NSRegularExpression(pattern: squareBracketPattern)

        let matches = splitRegex.matches(in: string)
        for match in matches {

            // remove the brackets if any
            var match = match
            if match.hasPrefix("("), match.hasSuffix(")") {
                match.removeFirst()
                match.removeLast()
            }
            let indexMatches = indexRegex.matches(in: match, options: [], range: match.nsRange)

            // try to get the indexes if any
            if let indexesMatch = try Self.extractIndexes(in: indexMatches, from: match) {
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

    public init(_ pathElements: PathElement...) {
        elements = pathElements
    }

    public init(_ pathElements: [PathElement]) {
        elements = pathElements
    }

    // MARK: - Functions

    static func extractIndexes(in indexMatches: [NSTextCheckingResult], from match: String) throws -> [PathElement]? {
        var indexMatches = indexMatches
        var elements = [PathElement]()

        guard let indexMatch = indexMatches.first else { // we have a first index, so retrieve it and the array name if possible
            return nil
        }

        // get the array index
        guard let index = Int(match[indexMatch.range]) else {
            throw PathExplorerError.invalidPathElement(match.pathValue)
        }

        if indexMatch.range.lowerBound == 1 {
            // specific case: the root element is an array: there is no array name
            elements.append(index.pathValue)
        } else {
            // get the array name
            let arrayName = String(match[0..<indexMatch.range.lowerBound - 1])

            elements.append(arrayName.pathValue)
            elements.append(index.pathValue)
        }

        // now retrieve the remaining indexes
        indexMatches.removeFirst()

        try indexMatches.forEach { indexMatch in
            guard let index = Int(match[indexMatch.range]) else { throw PathExplorerError.invalidPathElement(match.pathValue) }
            elements.append(index.pathValue)
        }

        return elements
    }

    public func appending(_ elements: PathElementRepresentable...) -> Path { Path(self.elements + elements) }
    public func appending(_ elements: PathElement...) -> Path { Path(self.elements + elements) }

    public mutating func removeLast() -> PathElement { elements.removeLast() }
}

extension Path: Collection {
    public func index(after i: Int) -> Int {
        return elements.index(after: i)
    }

    public subscript(elementIndex: Int) -> PathElement {
        assert(elementIndex >= startIndex && elementIndex <= endIndex)
        return elements[elementIndex]
    }

    mutating func append(_ element: PathElementRepresentable) {
        elements.append(element.pathValue)
    }

    mutating func popFirst() -> PathElement? {
        if let firstElement = elements.first {
            elements.removeFirst()
            return firstElement
        }
        return nil
    }
}

extension Path: CustomStringConvertible {

    public var description: String {
        var description = ""
        elements.forEach { element in
            switch element {
            case .index, .arrayCount:
                // remove the point added automatically to a path element
                if description.hasSuffix(".") {
                    description.removeLast()
                }
                description.append(element.description)

            case .key: description.append(element.description)
            }

            description.append(".")
        }
        // remove the last point if any
        if description.hasSuffix(".") {
            description.removeLast()
        }
        return description
    }
}

extension Path: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = PathElementRepresentable

    public init(arrayLiteral elements: PathElementRepresentable...) {
        self.elements = elements.map { $0.pathValue }
    }
}
