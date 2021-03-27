//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Optional {

    func unwrapOrThrow(error: Error) throws -> Wrapped {
        guard let wrapped = self else {
            throw error
        }
        return wrapped
    }

    func unwrapOrThrow(error: RuntimeError) throws -> Wrapped {
        try unwrapOrThrow(error: error)
    }
}
