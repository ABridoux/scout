public class KeyType<T: KeyAllowedType> {

    public static var string: StringType { StringType() }
    public static var int: IntType { IntType() }
    public static var real: RealType { RealType() }
    public static var bool: BoolType { BoolType() }
    public static var automatic: AutomaticType { AutomaticType() }
}

public final class StringType: KeyType<String> {}
public final class IntType: KeyType<Int> {}
public final class RealType: KeyType<Double> {}
public final class BoolType: KeyType<Bool> {}
public final class AutomaticType: KeyType<AnyHashable> {}

public protocol KeyAllowedType: LosslessStringConvertible {
    init(_ value: Any) throws
}

public extension KeyAllowedType {
    init(_ value: Any) throws {
        if let convertedValue = value as? Self {
            self = convertedValue
        } else if let stringValue = (value as? CustomStringConvertible)?.description, let convertedValue = Self(stringValue) {
            self = convertedValue
        } else {
            throw PathExplorerError.valueConversionError(value: value, type: String(describing: Self.Type.self))
        }
    }
}

extension String: KeyAllowedType {}
extension Int: KeyAllowedType {}
extension Double: KeyAllowedType {}
extension Bool: KeyAllowedType {}
extension AnyHashable: KeyAllowedType {}
