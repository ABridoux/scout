//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import BooleanExpressionEvaluation

// MARK: - FunctionPredicate

extension PathsFilter {

    /// Specify a function to filter the value
    public final class FunctionPredicate: ValuePredicate {

        // MARK: Type alias

        public typealias Evaluation = (ExplorerValue) throws -> Bool

        // MARK: Properties

        public var evaluation: Evaluation

        // MARK: Init

        public init(evaluation: @escaping Evaluation) {
            self.evaluation = evaluation
        }
    }
}

// MARK: - Evaluate

extension PathsFilter.FunctionPredicate {

    public func evaluate(with value: ExplorerValue) throws -> Bool {
        try evaluation(value)
    }
}
