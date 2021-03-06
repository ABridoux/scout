//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

/// Holds the types a key can have
public class KeyType<T: KeyAllowedType> {

    // MARK: - Constants

    public static var string: KeyTypes.StringType { KeyTypes.StringType() }
    public static var int: KeyTypes.IntType { KeyTypes.IntType() }
    public static var real: KeyTypes.RealType { KeyTypes.RealType() }
    // Same as `real`
    public static var double: KeyTypes.RealType { KeyTypes.RealType() }
    public static var bool: KeyTypes.BoolType { KeyTypes.BoolType() }

    /// Used to try to automatically infer the type
    static var automatic: KeyTypes.AutomaticType { KeyTypes.AutomaticType() }

    // MARK: - Initialization

    init(_ type: T.Type) {}
    fileprivate init() {}
}

/// Namespace for the phantom types to cast a value
public enum KeyTypes {
    public final class StringType: KeyType<String> {}
    public final class IntType: KeyType<Int> {}
    public final class RealType: KeyType<Double> {}
    public final class BoolType: KeyType<Bool> {}
    final class AutomaticType: KeyType<AnyHashable> {}
}
