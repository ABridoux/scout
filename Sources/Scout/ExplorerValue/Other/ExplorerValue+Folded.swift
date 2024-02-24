//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

// MARK: - Folding

extension ExplorerValue {

    // MARK: Constants

    private var foldedKey: String { Folding.foldedKey }
    private var foldedMark: String { Folding.foldedMark }

    // MARK: Fold

    func folded(upTo level: Int) -> Self {
        switch self {
        case .string, .int, .double, .bool, .data, .date:
            return self

        case .array(let array):
            if level <= 0 {
                return self.array <^> [Self.string(foldedMark)]
            } else {
                return self.array <^> array.map { $0.folded(upTo: level - 1) }
            }

        case .dictionary(let dict):
            if level <= 0 {
                return dictionary <^> [foldedKey: .string(foldedMark)]
            } else {
                return dictionary <^> dict.mapValues { $0.folded(upTo: level - 1) }
            }
        }
    }
}
