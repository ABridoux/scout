//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Collection of `PathElement`s to subscript a `PathExplorer`
public struct Path: Hashable {

    // MARK: - Constants

    public static var empty: Path { .init() }

    // MARK: - Properties

    private var elements = [PathElement]()

    // MARK: - Initialization

    private init(string: String, splitRegex: NSRegularExpression) {
        elements = splitRegex
            .matches(in: string)
            .map { PathElement(from: String($0).removingEnclosingBrackets()) }
    }

    /// Instantiate a `Path` for a string representing path components separated with the default separator '.'.
    ///
    /// ### Example with default separator '.'
    ///
    /// `computers[2].name` will make the path `["computers", 2, "name"]`
    ///
    /// `computer.general.serial_number` will make the path `["computer", "general", "serial_number"]`
    ///
    /// `company.computers[#]` will make the path `["company", "computers", PathElement.count]`
    ///
    /// - parameter string: The string representing the path
    /// - parameter separator: The separator used to split the string. Default is "."
    ///
    /// ### Brackets
    /// When enclosed with brackets, a path element will not be parsed. For example ```computer.(general.information).serial_number```
    /// will make the path ["computer", "general.information", "serial_number"]
    public init(string: String) {
        let pattern = Self.splitRegexPattern()
        let splitRegex: NSRegularExpression
        do {
            splitRegex = try NSRegularExpression(pattern: pattern)
        } catch {
            preconditionFailure(PathError.invalidRegex(pattern: pattern).localizedDescription)
        }

        self.init(string: string, splitRegex: splitRegex)
    }

    /// Instantiate a `Path` for a string representing path components separated with the separator.
    ///
    /// ### Example with default separator '.'
    ///
    /// `computers[2].name` will make the path `["computers", 2, "name"]`
    ///
    /// `computer.general.serial_number` will make the path `["computer", "general", "serial_number"]`
    ///
    /// `company.computers[#]` will make the path `["company", "computers", PathElement.count]`
    ///
    /// - parameter string: The string representing the path
    /// - parameter separator: The separator used to split the string. Default is "."
    ///
    /// ### Brackets
    /// When enclosed with brackets, a path element will not be parsed. For example ```computer.(general.information).serial_number```
    /// will make the path ["computer", "general.information", "serial_number"]
    ///
    /// ### Excluded separators
    /// The following separators will not work: '[', ']', '(', ')'.
    ///
    ///
    /// When using a special character for a [regular expression](https://developer.apple.com/documentation/foundation/nsregularexpression#1965589),
    /// it is required to quote it with "\\".
    public init(string: String, separator: String) throws {
        try Self.validate(separator: separator)
        let pattern = Self.splitRegexPattern(separator: separator)

        let splitRegex: NSRegularExpression
        do {
            splitRegex = try NSRegularExpression(pattern: pattern)
        } catch {
            throw PathError.invalidRegex(pattern: pattern)
        }

        self.init(string: string, splitRegex: splitRegex)
    }

    public init() {
        elements = []
    }

    /// Instantiate a path from `PathElementRepresentable`s
    public init(_ pathElements: [PathElementRepresentable]) {
        elements = pathElements.map(\.pathValue)
    }

    /// Instantiate a path from `PathElementRepresentable`s
    public init(_ pathElements: PathElementRepresentable...) {
        self.init(pathElements)
    }

    /// Instantiate a path from `PathElement`s
    public init(elements: PathElement...) {
        self.init(elements)
    }

    /// Instantiate a path from `PathElement`s
    public init(elements: [PathElement]) {
        self.init(elements)
    }

    // MARK: - Functions

    public func appending(_ elements: PathElementRepresentable...) -> Path { Path(self.elements + elements) }
    public func appending(_ elements: PathElement...) -> Path { Path(self.elements + elements) }
    public mutating func append(_ element: PathElementRepresentable) { elements.append(element.pathValue) }
}

// MARK: - Collection

extension Path: Collection {

    public var startIndex: Int { elements.startIndex }
    public var endIndex: Int { elements.endIndex }

    public func index(after i: Int) -> Int { elements.index(after: i) }

    public subscript(elementIndex: Int) -> PathElement {
        get { return elements[elementIndex] }
        set { elements[elementIndex] = newValue }
    }
}

extension Path: RangeReplaceableCollection {

    public mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>, with newElements: C)
    where Self.Element == C.Element {
        elements.replaceSubrange(subrange, with: newElements)
    }
}

extension Path: BidirectionalCollection {

    public func index(before i: Int) -> Int { elements.index(before: i) }
}

extension Path: MutableCollection {}
extension Path: RandomAccessCollection {}

// MARK: - ExpressibleByArrayLiteral

extension Path: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = PathElementRepresentable

    public init(arrayLiteral elements: PathElementRepresentable...) {
        self.elements = elements.map(\.pathValue)
    }
}
