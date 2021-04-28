//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension Dictionary where Key == String {

    /// Return the value for the key if it exists. Otherwise throw an error `missingKey`  with the best Jaro-Winkler match found
    func getJaroWinkler(key: String) throws -> Value {
        try self[key]
            .unwrapOrThrow(
                .missing(
                    key: key,
                    bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(keys))
                )
            )
    }
}

extension Dictionary {

    mutating func modifyEachValue(_ modify: (inout Value) throws -> Void) rethrows {
        self = try mapValues { value in
            var value = value
            try modify(&value)
            return value
        }
    }
}
