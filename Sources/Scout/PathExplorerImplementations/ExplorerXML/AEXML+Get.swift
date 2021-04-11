//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import AEXML

extension AEXMLElement {

    func getJaroWinkler(key: String) throws -> AEXMLElement {
        return try children
            .first { $0.name == key }
            .unwrapOrThrow(
                .missing(
                    key: key,
                    bestMatch: key.bestJaroWinklerMatchIn(propositions: Set(children.map(\.name)))
                )
            )
    }
}
