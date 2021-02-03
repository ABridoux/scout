//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import BooleanExpressionEvaluation

public enum PathsFilter {
    /// No filter on key or value.
    case targetOnly(ValueTarget)

    ///  Filter the keys based on a regular expression
    case key(regex: NSRegularExpression, target: ValueTarget)

    /// Filter the value based on predicates. The value is valid when one of the predicates validates it.
    case value([Predicate])

    ///  Filter the keys based on a regular expression and the value based on predicates. The value is valid when one of the predicates validates it.
    case keyAndValue(keyRegex: NSRegularExpression, valuePredicates: [Predicate])

    /// Allows group values (array, dictionaries)
    var groupAllowed: Bool {
        switch self {
        case .targetOnly(let target), .key(_, let target): return target.groupAllowed
        case .value, .keyAndValue: return false
        }
    }

    /// Allow single values (string, bool...)
    var singleAllowed: Bool {
        switch self {
        case .targetOnly(let target), .key(_, let target): return target.singleAllowed
        case .value, .keyAndValue: return true
        }
    }

    /// Validate a key when the filter has a key regex. `true` otherwise
    func validate(key: String) -> Bool {
        switch self {
        case .key(let regex, _), .keyAndValue(let regex, _): return regex.validate(key)
        case .value, .targetOnly: return true
        }
    }

    /// Validate an index when the filter is has no key regex.
    func validate(index: Int) -> Bool {
        switch self {
        case .key: return false
        case .value, .keyAndValue, .targetOnly: return true
        }
    }

    /// Validate a value when the filter has a value predicate. `true` otherwise
    func validate(value: Any) throws -> Bool {
        switch self {
        case .value(let predicates), .keyAndValue(_, let predicates):
            for predicate in predicates {
                if try predicate.evaluate(with: value) {
                    return true
                }
            }
            return false
        case .key, .targetOnly:
            return true
        }
    }
}

extension PathsFilter {

    /// No filter with target `singleAndGroup`
    public static var noFilter: PathsFilter { .targetOnly(.singleAndGroup) }

    /// Key filter with `singleAndGroup` target
    public static func key(regex: NSRegularExpression) -> PathsFilter { .key(regex: regex, target: .singleAndGroup) }

    public static func value(_ predicate: Predicate, _ additionalPredicates: Predicate...) -> Self {
        .value([predicate] + additionalPredicates)
    }

    public static func keyAndValue(keyRegex: NSRegularExpression, valuePredicates: Predicate, _ additionalPredicates: Predicate...) -> Self {
        .keyAndValue(keyRegex: keyRegex, valuePredicates: [valuePredicates] + additionalPredicates)
    }
}

// MARK: - Structs

extension PathsFilter {

    /// Specifies if group (array, dictionary) values, single (string, bool...) values or both should be targeted
    public enum ValueTarget: String, CaseIterable {
        /// Allows the key with a single or a group value
        case singleAndGroup
        /// Allows the key with a single value
        case group
        /// Allows the key with a group (array, dictionary) value
        case single

        /// Allows group values (array, dictionaries)
        var groupAllowed: Bool { [.singleAndGroup, .group].contains(self) }

        /// Allow single values (string, bool...)
        var singleAllowed: Bool { [.singleAndGroup, .single].contains(self) }
    }
}

extension PathsFilter {

    /// Allow to specify a boleean expression to filter the value
    ///
    /// The value is specified as the variable 'value' in the expression.
    /// - `value > 10`
    /// - `value hasPrefix 'Lou' && value hasSuffix 'lou'`
    ///
    /// - note: Public wrapper around BoleeanExpressionEvaluation.Expression
    public final class Predicate {
        private(set) var expression: Expression
        private(set) var mismatchedTypes: Set<ValueType> = []

        /// Specify a predicate with a 'value' variable that will be replaced with a concrete value during evaluation
        public init(format: String) throws {
            expression = try Expression(format)
        }

        /// Evaluate the predicate with the value.
        ///
        /// Ignore the error of mismatching type between the value and an operand and retruen `false
        public func evaluate(with value: Any) throws -> Bool {
            // if the type has already be invalidated, return false immediately
            if mismatchedTypes.contains(type(of: value)) { return false }

            do {
                return try expression.evaluate(with: ["value": String(describing: value)])
            } catch ExpressionError.mismatchingType {
                mismatchedTypes.insert(type(of: value))
                return false //ignore the error of wrong value type
            } catch {
                throw PathExplorerError.predicateError(description: error.localizedDescription)
            }
        }

        func type(of value: Any) -> ValueType {
            // use the initialisation from any allowing a string value
            if let _ = try? Int(value: value) {
                return .int
            } else if let _ = try? Double(value: value) {
                return .double
            } else if let _ = try? Bool(value: value) {
                return .bool
            } else {
                return .string
            }
        }
    }
}

extension PathsFilter.Predicate {

    enum ValueType: Hashable {
        case string, int, double, bool
    }
}
