//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

public enum PathsFilter {
    /// No filter on key or value.
    case targetOnly(ValueTarget)

    ///  Filter the keys based on a regular expression
    case key(regex: NSRegularExpression, target: ValueTarget)

    /// Filter the value based on predicates. The value is valid when one of the predicates validates it.
    case value([Predicate])

    /// Filter the keys based on a regular expression and the value based on predicates. The value is valid when one of the predicates validates it.
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

    ///  Filter the keys based on a regular expression. Default `singleAndGroup` target.
    public static func key(regex: NSRegularExpression) -> PathsFilter { .key(regex: regex, target: .singleAndGroup) }

    /// Filter the value based on expression predicates. The value is valid when one of the predicates validates it.
    public static func value(_ predicate: ExpressionPredicate, _ additionalPredicates: ExpressionPredicate...) -> Self {
        .value([predicate] + additionalPredicates)
    }

    /// Filter the keys based on a regular expression and the value based on expression predicates. The value is valid when one of the predicates validates it.
    public static func keyAndValue(keyRegex: NSRegularExpression, valuePredicates: ExpressionPredicate, _ additionalPredicates: ExpressionPredicate...) -> Self {
        .keyAndValue(keyRegex: keyRegex, valuePredicates: [valuePredicates] + additionalPredicates)
    }

    /// Filter the keys based on a regular expression and the value based on a function predicate. The value is valid when one of the predicates validates it.
    public static func keyAndValue(keyRegex: NSRegularExpression, valuePredicate: FunctionPredicate) -> Self {
        .keyAndValue(keyRegex: keyRegex, valuePredicates: [valuePredicate])
    }

    /// Key filter with a pattern for the regular expression.
    /// - Throws: If the pattern is invalid
    public static func key(pattern: String, target valueTarget: ValueTarget = .singleAndGroup) throws -> PathsFilter {
        try .key(regex: NSRegularExpression(pattern: pattern), target: valueTarget)
    }

    /// Value filter with formats for the expression predicates.
    /// - Throws: If one format is invalid
    public static func value(_ format: String, _ additionalPredicatesFormats: String...) throws -> Self {
        let predicate = try ExpressionPredicate(format: format)
        let additionalPredicates = try additionalPredicatesFormats.map { try ExpressionPredicate(format: $0) }
        return .value([predicate] + additionalPredicates)
    }

    /// Filter the keys based on a regular expression and the value based on predicates.
    /// - Throws: If the regular expression pattern is invalid or one predicate format is invalid
    public static func keyAndValue(pattern: String, valuePredicatesFormat firstFormat: String, _ additionalPredicatesFormats: String...) throws -> Self {
        let regex = try NSRegularExpression(pattern: pattern)
        let firstPredicate = try ExpressionPredicate(format: firstFormat)
        let additionalPredicates = try additionalPredicatesFormats.map { try ExpressionPredicate(format: $0) }
        return .keyAndValue(keyRegex: regex, valuePredicates: [firstPredicate] + additionalPredicates)
    }

    // Filter the keys based on a regular expression and the value based on a function predicate.
    /// - Throws: If the regular expression pattern is invalid or one predicate format is invalid
    public static func keyAndValue(pattern: String, valuePredicate: FunctionPredicate) throws -> Self {
        let regex = try NSRegularExpression(pattern: pattern)
        return .keyAndValue(keyRegex: regex, valuePredicates: [valuePredicate])
    }
}
