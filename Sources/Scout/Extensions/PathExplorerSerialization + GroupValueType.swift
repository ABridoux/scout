//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    typealias DictionaryValue = [String: Any]
    typealias ArrayValue = [Any]

    /// The  group types `value` can be casted as.
    class GroupValue<Type> {
        static var dictionary: GroupValue<DictionaryValue> { GroupValue<DictionaryValue>() }
        static var array: GroupValue<ArrayValue> { GroupValue<ArrayValue>() }

        private init() {}
    }

    /// Try to cast the given value as the given type (dictionary or array), throwing the error if not possible
    func cast<T>(_ value: Any, as type: GroupValue<T>, orThrow error: PathExplorerError) throws -> T {
        if let castedValue = value as? T {
            return castedValue
        } else {
            throw error
        }
    }
}
