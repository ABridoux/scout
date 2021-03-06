//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Optional {

    func unwrapOrThrow(error: Error) throws -> Wrapped {
        guard let wrapped = self else {
            throw error
        }
        return wrapped
    }

    func unwrapOrThrow(_ error: RuntimeError) throws -> Wrapped {
        try unwrapOrThrow(error: error)
    }
}
