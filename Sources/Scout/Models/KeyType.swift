//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

/// Namespace for the phantom types to cast a value
public enum KeyTypes {

    /// Holds the types a key can have
    public class KeyType<T: KeyAllowedType> {

        // MARK: - Constants

        public static var string: StringType { StringType() }
        public static var int: IntType { IntType() }
        public static var real: RealType { RealType() }
        // Same as `real`
        public static var double: RealType { RealType() }
        public static var bool: BoolType { BoolType() }
        public static var data: DataType { DataType() }

        /// Used to try to automatically infer the type
        public static var automatic: AutomaticType { KeyTypes.AutomaticType() }

        // MARK: - Initialization

        init(_ type: T.Type) {}
        fileprivate init() {}
    }

    public final class StringType: KeyType<String> {}
    public final class IntType: KeyType<Int> {}
    public final class RealType: KeyType<Double> {}
    public final class BoolType: KeyType<Bool> {}
    public final class DataType: KeyType<Data> {}
    public final class AutomaticType: KeyTypes.KeyType<AnyHashable> {}
}
