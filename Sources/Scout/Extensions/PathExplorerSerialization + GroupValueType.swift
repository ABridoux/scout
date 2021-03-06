//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

extension PathExplorerSerialization {

    typealias DictionaryValue = [String: Any]
    typealias ArrayValue = [Any]

    static var dictionaryTypeDescription: String { GroupValue<DictionaryValue>.dictionary.typeDescription }
    static var arrayTypeDescription: String { GroupValue<ArrayValue>.array.typeDescription }

    /// The  group types `value` can be casted as.
    struct GroupValue<Type> {
        var typeDescription: String

        static var dictionary: GroupValue<DictionaryValue> { GroupValue<DictionaryValue>(typeDescription: "dictionary") }
        static var array: GroupValue<ArrayValue> { GroupValue<ArrayValue>(typeDescription: "array") }

        static func dictionary<Value: KeyAllowedType>(_ value: KeyTypes.KeyType<Value>) -> GroupValue<[String: Value]> {
            GroupValue<[String: Value]>(typeDescription: "dictionary(\(Value.typeDescription)")

        }
        static func array<Value: KeyAllowedType>(_ value: KeyTypes.KeyType<Value>) -> GroupValue<[Value]> {
            GroupValue<[Value]>(typeDescription: "array(\(Value.typeDescription)")
        }

        private init(typeDescription: String) {
            self.typeDescription = typeDescription
        }
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
