//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import AEXML

extension KeyTypes {

    /// Namespace for the phantom types to get a value
    public enum Get {}
}

extension KeyTypes.Get {

    /// Holds the available value types to export a `PathExplorer` value
    public class ValueType<Value> {

        fileprivate init() {}

        public static var string: StringValue { StringValue() }
        public static var int: IntValue { IntValue() }
        public static var double: DoubleValue { DoubleValue() }
        public static var bool: BoolValue { BoolValue() }
        public static var data: DataValue { DataValue() }

        /// When dealing with arrays or dictionaries, export the elements as `Any`
        public static var any: AnyValue { AnyValue() }

        /// Get the value `Value` from the `AEXMLElement`
        /// - note: Do not call `super`
        func value(from element: AEXMLElement) -> Value? {
            preconditionFailure("Should be overridden")
        }
    }
}

extension KeyTypes.Get {

    public final class StringValue: ValueType<String> {

        override final func value(from element: AEXMLElement) -> String? {
            element.value
        }
    }

    public final class IntValue: ValueType<Int> {

        override final func value(from element: AEXMLElement) -> Int? {
            element.int
        }
    }

    public final class DoubleValue: ValueType<Double> {

        override final func value(from element: AEXMLElement) -> Double? {
            element.double
        }
    }

    public final class BoolValue: ValueType<Bool> {

        override final func value(from element: AEXMLElement) -> Bool? {
            element.bool
        }
    }

    public final class DataValue: ValueType<Data> {

        override final func value(from element: AEXMLElement) -> Data? {
            element.string.data(using: .utf8)
        }
    }

    public final class AnyValue: ValueType<Any> {

        override final func value(from element: AEXMLElement) -> Any? {
            if let int = element.int {
                return int
            } else if let double = element.double {
                return double
            } else if let bool = element.bool {
                return bool
            } else if let string = element.value {
                return string
            }

            // data element value is not valid
            return nil
        }
    }
}
