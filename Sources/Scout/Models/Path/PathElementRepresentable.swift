//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

/// Protocol to allow to subscript a `PathExplorer` without using directly the `PathElement` enum.
///
/// As `PathElement` already conforms to `ExpressibleByStringLiteral` and `ExpressibleByIntegerLiteral`,
/// it is possible to instantiate a Path without the need of using the `PathElementRepresentable` protocol:
/// ```
/// let path: Path = ["people", "Tom", "hobbies", 1]
/// ```
/// But the "Expressible" protocols do not allow to do the same with variables.
/// Thus, using `PathElementRepresentable` allows to instantiate a Path from a mix of Strings and Integers variables:
/// ```
/// let firstKey = "people"
/// let secondKey = "Tom"
/// let thirdKey = "hobbies"
/// let index = 1
/// let path: Path = [firstKey, secondKey, thirdKey, index]
/// ```
public protocol PathElementRepresentable {
    var pathValue: PathElement { get }
}

extension String: PathElementRepresentable {
    public var pathValue: PathElement { indexPathElement ?? countPathElement ?? keysListPathElements ?? slicePathElement ?? filterPathElements ?? .key(self) }

    /// Not `nil` if the string can be transformed to a `PathElement.index`
    var indexPathElement: PathElement? {
        guard self.hasPrefix("["), self.hasSuffix("]") else {
            return nil
        }

        var copy = self
        copy.removeFirst()
        copy.removeLast()

        guard let index = Int(copy) else { return nil }
        return PathElement.index(index)
    }

    /// Not `nil` if the string can be transformed to a `PathElement.count`
    var countPathElement: PathElement? { self == PathElement.count.description ? .count : nil }

    /// Not `nil` if the string can be transformed to a `PathElement.keysList`
    var keysListPathElements: PathElement? { self == PathElement.keysList.description ? .keysList : nil }

    /// Not `nil` if the string can be transformed to a `PathElement.slice`
    var slicePathElement: PathElement? {
        guard
            hasPrefix("["),
            hasSuffix("]")
        else { return nil }

        var copy = self
        copy.removeFirst()
        copy.removeLast()

        let splitted = copy.split(separator: ":", omittingEmptySubsequences: false)

        guard splitted.count == 2 else { return nil }

        var lower: Bounds.Bound
        if splitted[0] == "" {
            lower = .first
        } else if let lowerValue = Int(splitted[0]) {
            lower = .init(lowerValue)
        } else {
            return nil
        }

        var upper: Bounds.Bound
        if splitted[1] == "" {
            upper = .last
        } else if let upperValue = Int(splitted[1]) {
            upper = .init(upperValue)
        } else {
            return nil
        }

        return .slice(lower, upper)
    }

    /// Not `nil` if the string can be transformed to a `PathElement.filter`
    var filterPathElements: PathElement? {
        guard isEnclosed(by: "#")  else { return nil }
        var copy = self
        copy.removeFirst()
        copy.removeLast()
        copy = copy.replacingOccurrences(of: "\\#", with: "#")
        return .filter(copy)
    }
}

extension Int: PathElementRepresentable {
    public var pathValue: PathElement { .index(self) }
}

extension PathElement: PathElementRepresentable {
    public var pathValue: PathElement { self }
}
