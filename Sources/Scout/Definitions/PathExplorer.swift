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

    /// String representation of value property (if value is nil this is empty String).
    var stringValue: String { get }

    // MARK: - Initialization

    init(data: Data) throws
    init(value: Any)

    // MARK: - Functions

    // MARK: CRUD

    func get(_ path: Path) throws -> Self
    func get(_ pathElements: PathElement...) throws -> Self

    mutating func set(_ path: Path, to newValue: Any) throws
    mutating func set(_ pathElements: PathElement..., to newValue: Any) throws

    mutating func set(_ path: Path, keyNameTo newKeyName: String) throws
    mutating func set(_ pathElements: PathElement..., keyNameTo newKeyName: String) throws

    mutating func delete(_ path: Path) throws
    mutating func delete(_ pathElements: PathElement...) throws

    mutating func add(_ newValue: Any, at path: Path) throws
    mutating func add(_ newValue: Any, at pathElements: PathElement...) throws

    // MARK: Export

    func exportData() throws -> Data
    func exportString() throws -> String
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

// MARK: Data validation

extension PathExplorer {

    /// Ensure a value as a correct type
    /// - Parameter value: The value to convert
    /// - Throws: PathExplorerError.invalidValue
    /// - Returns: The value converted to the optimal type
    func convert(_ value: Any) throws -> Any {
        // try single types
        if let stringValue = value as? String {
            if let bool = Bool(stringValue) {
                return bool
            } else if let int = Int(stringValue) {
                return int
            } else if let double = Double(stringValue) {
                return double
            } else {
                return stringValue
            }
        }

        // try group types
        switch value {
        case let dict as [String: Any]:
            return dict
        case let array as [Any]:
            return array
        default:
            throw PathExplorerError.invalidValue(value)
        }
    }
}
