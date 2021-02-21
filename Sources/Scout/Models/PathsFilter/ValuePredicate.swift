//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import BooleanExpressionEvaluation

/// Expression or function to evaluate a value
public protocol ValuePredicate {

    /// Evaluate the predicate with the value.
    ///
    /// - note: Ignore the error of mismatching types between the value and an operand and return `false`
    func evaluate(with value: Any) throws -> Bool
}

extension PathsFilter {

    /// Specify a boleean expression to filter the value
    ///
    /// The value is specified as the variable 'value' in the expression.
    /// - `value > 10`
    /// - `value hasPrefix 'Lou' && value hasSuffix 'lou'`
    ///
    /// - note: Public wrapper around BoleeanExpressionEvaluation.Expression
    public final class ExpressionPredicate: ValuePredicate {
        private(set) var expression: Expression

        /// The value types that the operators in the expression support
        private(set) var operatorsValueTypes: Set<ValueType>

        /// Specify a predicate with a 'value' variable that will be replaced with a concrete value during evaluation
        public init(format: String) throws {
            expression = try Expression(format)
            operatorsValueTypes = expression.operators.reduce(Self.allValueTypesSet) { $0.intersection(Self.valueTypes(of: $1)) }
        }

        /// Evaluate the predicate with the value.
        ///
        /// - note: Ignore the error of mismatching types between the value and an operand and return `false`
        public func evaluate(with value: Any) throws -> Bool {
            let valueType = type(of: value)

            // exit immediately if the operators do not support the value type
            guard operatorsValueTypes.contains(valueType) else { return false }

            do {
                return try expression.evaluate(with: ["value": String(describing: value)])
            } catch ExpressionError.mismatchingType {
                // error of mistmatching type for `valueType`. Remove it from the supported types
                operatorsValueTypes.remove(valueType)
                return false //ignore the error of wrong value type
            } catch {
                throw PathExplorerError.predicateError(predicate: expression.description, description: error.localizedDescription)
            }
        }

        func type(of value: Any) -> ValueType {
            // use the initialisation from any allowing a string value
            if let _ = try? Double(value: value) {
                return .double
            } else if let _ = try? Bool(value: value) {
                return .bool
            } else {
                return .string
            }
        }
    }
}

extension PathsFilter {

    /// Specify a function to filter the value
    public final class FunctionPredicate: ValuePredicate {

        public typealias Evaluation = (Any) throws -> Bool
        public var evaluation: Evaluation

        public init(evaluation: @escaping Evaluation) {
            self.evaluation = evaluation
        }

        public func evaluate(with value: Any) throws -> Bool {
            try evaluation(value)
        }
    }
}

extension PathsFilter.ExpressionPredicate {

    enum ValueType: Hashable, CaseIterable {
        case string, double, bool
    }

    static var allValueTypesSet: Set<ValueType> {
        Set(ValueType.allCases)
    }
}

extension PathsFilter.ExpressionPredicate {

    static func valueTypes(of comparisonOperator: Operator) -> Set<ValueType> {
        switch comparisonOperator {
        case .equal, .nonEqual:
            return allValueTypesSet

        case .greaterThan, .greaterThanOrEqual, .lesserThan, .lesserThanOrEqual:
            return [.double, .string]

        case .contains, .isIn, .hasPrefix, .hasSuffix:
            return [.string]

        default:
            assertionFailure("Operator not handled: \(comparisonOperator)")
            return allValueTypesSet
        }
    }
}
