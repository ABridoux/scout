//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import BooleanExpressionEvaluation

// MARK: - ValuePredicate

/// Expression or function to evaluate a value
public protocol ValuePredicate {

    /// Evaluate the predicate with the value.
    ///
    /// - note: Ignore the error of mismatching types between the value and an operand and return `false`
    func evaluate(with value: ExplorerValue) throws -> Bool
}
