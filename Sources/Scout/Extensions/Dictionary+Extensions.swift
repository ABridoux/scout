//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Dictionary where Key == String {

    /// Return the value for the key if it exists. Otherwise throw an error `missingKey`  with the best Jaro-Winkler match found
    func getJaroWinkler(key: String) throws -> Value {
        try self[key].unwrapOrThrow(.missing(key: key, bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(keys))))
    }
}
