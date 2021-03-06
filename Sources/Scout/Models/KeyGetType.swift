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

        /// When dealing with arrays or dictionaries, export the elements as `Any`
        public static var any: AnyValue { AnyValue() }

        func value(from element: AEXMLElement) -> Value? {
            // should be overridden
            fatalError()
        }
    }
}

extension KeyTypes.Get {

    public final class StringValue: ValueType<String> {

        override func value(from element: AEXMLElement) -> String? {
            element.value
        }
    }

    public final class IntValue: ValueType<Int> {

        override func value(from element: AEXMLElement) -> Int? {
            element.int
        }
    }

    public final class DoubleValue: ValueType<Double> {

        override func value(from element: AEXMLElement) -> Double? {
            element.double
        }
    }

    public final class BoolValue: ValueType<Bool> {

        override func value(from element: AEXMLElement) -> Bool? {
            element.bool
        }
    }

    public final class AnyValue: ValueType<Any> {

        override func value(from element: AEXMLElement) -> Any? {
            if let string = element.value {
                return string
            } else if let int = element.int {
                return int
            } else if let double = element.double {
                return double
            } else if let bool = element.bool {
                return bool
            } else {
                return nil
            }
        }
    }
}
