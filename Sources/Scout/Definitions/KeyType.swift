public class KeyType<T: KeyAllowedType> {

    public static var string: StringType { StringType() }
    public static var int: IntType { IntType() }
    public static var real: RealType { RealType() }
    public static var bool: BoolType { BoolType() }
    public static var automatic: AutomaticType { AutomaticType() }

    public init(_ type: T.Type) {}

    public init() {}
}

public final class StringType: KeyType<String> {}
public final class IntType: KeyType<Int> {}
public final class RealType: KeyType<Double> {}
public final class BoolType: KeyType<Bool> {}
public final class AutomaticType: KeyType<AnyHashable> {}

public protocol KeyAllowedType: LosslessStringConvertible, Equatable {
    static var typeDescription: String { get }

    init( value: Any) throws
}

public extension KeyAllowedType {

    init(value: Any) throws {
        if let convertedValue = value as? Self {
            self = convertedValue
            return
        }

        if let stringValue = (value as? CustomStringConvertible)?.description {

            if Self.self == Bool.self {
                // specific case for Bool values as we allow other string than "true" or "false"
                if Bool.trueSet.contains(stringValue) {
                    self = Self("true")!
                    return
                } else if Bool.falseSet.contains(stringValue) {
                    self = Self("false")!
                    return
                }
            } else if let convertedValue = Self(stringValue) {
                self = convertedValue
                return
            }
        }

        throw PathExplorerError.valueConversionError(value: String(describing: value), type: String(describing: Self.typeDescription))
    }
}

extension String: KeyAllowedType {
    public static let typeDescription = "String"
}

extension Int: KeyAllowedType {
    public static let typeDescription = "Integer"
}

extension Double: KeyAllowedType {
    public static let typeDescription = "Real"
}

extension Bool: KeyAllowedType {
    public static let typeDescription = "Boolean"
}

extension AnyHashable: KeyAllowedType {
    public static let typeDescription = "Automatic"
}

extension Bool {
    static let trueSet: Set<String> = ["y", "yes", "Y", "Yes", "YES", "t", "true", "T", "True", "TRUE"]
    static let falseSet: Set<String> = ["n", "no", "N", "No", "NO", "f", "false", "F", "False", "FALSE"]
}
