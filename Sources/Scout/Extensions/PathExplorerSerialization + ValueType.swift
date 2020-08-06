//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    typealias DictionaryValue = [String: Any]
    typealias ArrayValue = [Any]

    /// The types `value` can be casted as.
    class Value<Type> {
        static var dictionary: Value<DictionaryValue> { Value<DictionaryValue>() }
        static var array: Value<ArrayValue> { Value<ArrayValue>() }

        private init() {}
    }

    /// Try to cast the given value as the given type (dictionary or array), throwing the error if not possible
    func cast<T>(_ value: Any, as type: Value<T>, orThrow error: PathExplorerError) throws -> T {
        if let castedValue = value as? T {
            return castedValue
        } else {
            throw error
        }
    }
}
