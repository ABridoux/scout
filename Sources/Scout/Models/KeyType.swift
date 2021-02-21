//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

/// Holds the types a key can have
public class KeyType<T: KeyAllowedType> {

    // MARK: - Constants

    public static var string: StringType { StringType() }
    public static var int: IntType { IntType() }
    public static var real: RealType { RealType() }
    public static var bool: BoolType { BoolType() }

    /// Used to try to automatically infer the type
    public static var automatic: AutomaticType { AutomaticType() }

    // MARK: - Initialization

    public init(_ type: T.Type) {}

    public init() {}
}

public final class StringType: KeyType<String> {}
public final class IntType: KeyType<Int> {}
public final class RealType: KeyType<Double> {}
public final class BoolType: KeyType<Bool> {}
public final class AutomaticType: KeyType<AnyHashable> {}
