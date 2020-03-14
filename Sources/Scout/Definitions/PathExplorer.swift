import Foundation


/// Wrap different structs to explore several format: Json, Plist and Xml
public protocol PathExplorer:
    ExpressibleByStringLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral
where
    StringLiteralType == String,
    BooleanLiteralType == Bool,
    IntegerLiteralType == Int,
    FloatLiteralType == Double {

    // MARK: - Properties

    var string: String? { get }
    var bool: Bool? { get }
    var int: Int? { get }
    var real: Double? { get }
    var date: Date? { get }

    // MARK: - Initialization

    init(data: Data) throws
    init(value: Any)

    // MARK: - Functions

    // MARK: Subscript

    subscript(_ key: String) -> Self { get set }
    subscript(_ index: Int) -> Self { get set }
    subscript(_ path: PathElement...) -> Self { get set }
    subscript(_ path: Path) -> Self { get set }

    // MARK: Export

    func exportData() throws -> Data
    func outputString() throws -> String?
}

// MARK: Literal types extensions

extension PathExplorer {
    public init(stringLiteral value: Self.StringLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer  {
    public init(booleanLiteral value: Self.BooleanLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer {
    public init(integerLiteral value: Self.IntegerLiteralType) {
        self.init(value: value)
    }
}

extension PathExplorer {
    public init(floatLiteral value: Self.FloatLiteralType) {
        self.init(value: value)
    }
}
