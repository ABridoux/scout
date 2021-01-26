//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Collection of `PathElement`s to subscript a `PathExplorer`
public struct Path: Hashable {

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

// MARK: Collection

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

// MARK: String convertible

extension Path: CustomStringConvertible, CustomDebugStringConvertible {

    /// Prints all the elements in the path, with the default separator
    /// #### Complexity
    /// O(n) with `n` number of elements in the path
    public var description: String { computeDescription() }

    public var debugDescription: String { description }

    func computeDescription(ignore: ((PathElement) -> Bool)? = nil) -> String {
        var description = ""

        elements.forEach { element in
            if let ignore = ignore, ignore(element) { return }

            switch element {

            case .index, .count, .slice, .keysList:
                // remove the point added automatically to a path element
                if description.hasSuffix(Self.defaultSeparator) {
                    description.removeLast()
                }
                description.append(element.description)

            case .filter(let pattern):
                description.append("#\(pattern)#")

            case .key:
                description.append(element.description)
            }

            description.append(Self.defaultSeparator)
        }

        // remove the last point if any
        if description.hasSuffix(Self.defaultSeparator) {
            description.removeLast()
        }

        return description
    }
}

extension Path: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = PathElementRepresentable

    public init(arrayLiteral elements: PathElementRepresentable...) {
        self.elements = elements.map(\.pathValue)
    }
}

// MARK: - Flattening

extension Path {

    /// Compute the path by changing the special path elements like slices or filters
    ///
    /// Filters are removed. Slices are changed to indexes to target the path.
    /// #### Complexity
    /// O(n) with `n` number of elements in the path
    public func flattened() -> Path {
        var indexes = [(index: Int, value: Int)]()
        var slices = [(index: Int, lowerBound: Int, upperBound: Int)]()
        var keys = [(index: Int, name: String)]()
        var filters = [(index: Int, pattern: String)]()
        var newElements = [PathElement]()

        elements.enumerated().forEach { (index, element) in
            let element = elements[index]

            switch element {
            case .count, .keysList:
                break

            case .key(let name):
                keys.append((index, name))

            case .filter(let pattern):
                filters.append((index, pattern))

            case .index(let indexValue):
                indexes.append((index: index, value: indexValue))

            case .slice(let bounds):
                guard
                    let lowerBound = bounds.lastComputedLower,
                    let upperBound = bounds.lastComputedUpper
                else { break }
                #warning("Handle negative indexes when added")

                slices.append((index, lowerBound, upperBound))
                indexes.removeAll()
            }

            newElements.append(element)
        }

        var indexesToRemove = [Int]()

        if slices.count == 1, let firstSlice = slices.first, let index = indexes.first {
            let newIndex = firstSlice.lowerBound + index.value
            newElements[firstSlice.index] = .index(newIndex)
            indexesToRemove.append(index.index)
            slices.removeFirst()
        } else if let firstSlice = slices.first, let lastIndex = indexes.popLast() {
            let newIndex = firstSlice.lowerBound + lastIndex.value
            newElements[firstSlice.index] = .index(newIndex)
            indexesToRemove.append(lastIndex.index)
            slices.removeFirst()
        }

        slices.enumerated().forEach { (index, slice) in
            let arrayIndex = indexes[index]
            let newIndex = slice.lowerBound + arrayIndex.value
            newElements[slice.index] = .index(newIndex)
            indexesToRemove.append(arrayIndex.index)
        }

        var filtersIterator = filters.reversed().makeIterator()
        var keysIterator = keys.reversed().makeIterator()

        while let filter = filtersIterator.next(), let key = keysIterator.next() {
            guard
                let regex = try? NSRegularExpression(pattern: filter.pattern),
                regex.validate(key.name)
            else { continue }
            newElements[filter.index] = .key(key.name)
            indexesToRemove.append(key.index)
        }

        indexesToRemove.sorted { $1 < $0 }.forEach { newElements.remove(at: $0) }

        return Path(newElements)
    }
}

// MARK: - Regular expression

extension Path {

    /// Last key component matching the regular expression
    public func lastKeyComponent(matches regularExpression: NSRegularExpression) -> Bool {
        let lastKey = elements.last { (element) -> Bool in
            if case .key = element {
                return true
            }
            return false
        }
        guard case let .key(name) = lastKey else { return false }

        return regularExpression.validate(name)
    }
}

// MARK: - Map functions

public extension Path {

    /// Retrieve all the index elements
    var compactMapIndexes: [Int] {
        compactMap {
            if case let .index(index) = $0 {
                return index
            }
            return nil
        }
    }

    /// Retrieve all the key elements
    var compactMapKeys: [String] {
        compactMap {
            if case let .key(name) = $0 {
                return name
            }
            return nil
        }
    }
}

// MARK: - Paths collection

public extension Collection where Element == Path {

    /// Sort by key or index when found at the same position
    func sortedByKeysAndIndexes() -> [Path] {
        sorted { (lhs, rhs) in

            var lhsIterator = lhs.makeIterator()
            var rhsIterator = rhs.makeIterator()

            while let lhsElement = lhsIterator.next(), let rhsElement = rhsIterator.next() {
                switch (lhsElement, rhsElement) {

                case (.key(let lhsLabel), .key(let rhsLabel)):
                    if lhsLabel != rhsLabel {
                        return lhsLabel < rhsLabel
                    }

                case (.index(let lhsIndex), .index(let rhsIndex)):
                    if lhsIndex != rhsIndex {
                        return lhsIndex < rhsIndex
                    }

                default:
                    return true
                }
            }

            return true
        }
    }
}
