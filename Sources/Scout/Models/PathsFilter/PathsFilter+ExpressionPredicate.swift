//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import BooleanExpressionEvaluation

// MARK: - ExpressionPredicate

extension PathsFilter {

    /// Specify a `String` boolean expression to filter the value.
    ///
    /// The value is specified as the variable 'value' in the expression.
    /// - `value > 10`
    /// - `value hasPrefix 'Lou' && value hasSuffix 'lou'`
    ///
    /// - note: Public wrapper around `BooleanExpressionEvaluation/Expression`.
    public final class ExpressionPredicate: ValuePredicate {

        // MARK: Properties

        private(set) var expression: Expression

        /// The value types that the operators in the expression support
        private(set) var operatorsValueTypes: Set<ValueType>

        // MARK: Init

        /// Specify a predicate with a 'value' variable that will be replaced with a concrete value during evaluation
        public init(format: String) throws {
            expression = try Expression(format)
            operatorsValueTypes = expression.operators.reduce(Self.allValueTypesSet) { $0.intersection(Self.valueTypes(of: $1)) }
        }
    }
}

// MARK: - Evaluate

extension PathsFilter.ExpressionPredicate {

    /// Evaluate the predicate with the value.
    ///
    /// - note: Ignore the error of mismatching types between the value and an operand and return `false`
    public func evaluate(with value: ExplorerValue) throws -> Bool {
        let valueType = try type(of: value)

        // exit immediately if the operators do not support the value type
        guard operatorsValueTypes.contains(valueType) else { return false }

        do {
            return try expression.evaluate(with: ["value": String(describing: value)])
        } catch ExpressionError.mismatchingType {
            // error of mismatching type for `valueType`. Remove it from the supported types
            operatorsValueTypes.remove(valueType)
            return false // ignore the error of wrong value type
        } catch {
            throw ExplorerError.predicateNotEvaluatable(expression.description, description: error.localizedDescription)
        }
    }
}

// MARK: - Type

extension PathsFilter.ExpressionPredicate {

    func type(of value: ExplorerValue) throws -> ValueType {
        switch value {
        case .double, .int: return .double
        case .bool: return .bool
        case .string: return .string
        default: throw ExplorerError.predicateNotEvaluatable(expression.description, description: "Unsupported type for value \(value)")
        }
    }

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

// MARK: - ValueType

extension PathsFilter.ExpressionPredicate {

    enum ValueType: Hashable, CaseIterable {
        case string, double, bool
    }

    static var allValueTypesSet: Set<ValueType> {
        Set(ValueType.allCases)
    }
}
