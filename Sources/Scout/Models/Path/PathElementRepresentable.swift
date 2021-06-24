//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
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
/// ```swift
/// let tom = "Tom"
/// let hobbies = "hobbies"
/// let index = 1
/// let path: Path = [tom, hobbies, index]
/// ```
/// - note: This only works for keys and indexes. When dealing with other elements like `.count` or `.slice`,
/// it's required to use the full name `PathElement.count`, `PathElement.slice`. Otherwise,
/// the `Path.init(element:)` works with `PathElement` directly although the possibility to use variables
/// without the `PathElement` specification becomes unavailable.
public protocol PathElementRepresentable {
    var pathValue: PathElement { get }
}

extension String: PathElementRepresentable {
    public var pathValue: PathElement { .key(self) }
}

extension Int: PathElementRepresentable {
    public var pathValue: PathElement { .index(self) }
}

extension PathElement: PathElementRepresentable {
    public var pathValue: PathElement { self }
}
