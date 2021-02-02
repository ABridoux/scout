//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import BooleanExpressionEvaluation

public enum PathsFilter {
    case targetOnly(ValueTarget)
    case key(regex: NSRegularExpression, target: ValueTarget)
    case value(Predicate)
    case keyAndValue(keyRegex: NSRegularExpression, valuePredicate: Predicate)

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

    /// Validate a key when the filter has a key regex
    func validate(key: String) -> Bool {
        switch self {
        case .key(let regex, _), .keyAndValue(let regex, _): return regex.validate(key)
        case .value, .targetOnly: return true
        }
    }

    /// Validate an index when the filter is has no key regex
    func validate(index: Int) -> Bool {
        switch self {
        case .key: return false
        case .value, .keyAndValue, .targetOnly: return true
        }
    }

    /// Validate a value when the filter has a value predicate
    func validate(value: Any) -> Bool {
        switch self {
        case .value(let predicate), .keyAndValue(_, let predicate): return predicate.evaluate(with: value)
        case .key, .targetOnly:
            return true
        }
    }
}

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

    /// Allow to specify a bollean expression to filter the value
    ///
    /// The value is specified as the variable 'value' in the expression.
    /// - `value > 10`
    /// - `value hasPrefix 'Lou' && value hasSuffix 'lou'`
    /// 
    /// - note: Public wrapper around BoleeanExpressionEvaluation.Expression
    public struct Predicate {
        var expression: Expression

        init(expression: Expression) {
            self.expression = expression
        }

        /// Specify a predicate with a 'value' variable that will be replaced with a concrete value during evaluation
        public init(format: String) throws {
            expression = try Expression(format)
        }

        public func evaluate(with value: Any) -> Bool {
            let result = try? expression.evaluate(with: ["variable": String(describing: value)])
            return result ?? true //ignore the error of wrong value type
        }
    }
}

extension PathsFilter {

    /// No filter with target `singleAndGroup`
    public static var noFilter: PathsFilter { .targetOnly(.singleAndGroup) }

    /// Key filter with `singleAndGroup` target
    public static func key(regex: NSRegularExpression) -> PathsFilter { .key(regex: regex, target: .singleAndGroup) }
}
