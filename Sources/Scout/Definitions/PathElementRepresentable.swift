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
    public var pathValue: PathElement { .key(self) }
}

extension Int: PathElementRepresentable {
    public var pathValue: PathElement { .index(self) }
}

extension PathElement: PathElementRepresentable {
    public var pathValue: PathElement { self }
}
