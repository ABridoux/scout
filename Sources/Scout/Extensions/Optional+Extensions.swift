//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

infix operator !!

/// Force unwrap an optional when required, with a relevant error message if the optional is `nil`
/// - Parameters:
///   - optional: The optional to unwrap
///   - errorMessage: An error message
/// - Returns: The unwrapped optional
/// - note: Idea from [Advanced Swift](https://www.objc.io/books/advanced-swift/)
func !!<T>(optional: T?, errorMessage: @autoclosure () -> String) -> T {
    if let unwrapped = optional {
        return unwrapped
    }
    fatalError(errorMessage())
}

extension Optional {

    func unwrapOrThrow(error: Error) throws -> Wrapped {
        guard let wrapped = self else {
            throw error
        }
        return wrapped
    }

    func unwrapOrThrow(_ error: ValueTypeError) throws -> Wrapped {
        try unwrapOrThrow(error: error)
    }
}
