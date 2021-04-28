//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension ExplorerXML {

    private var foldedKey: String { Folding.foldedKey }
    private var foldedMark: String { Folding.foldedMark }
    var foldedRegexPattern: String { #"(?<=>)\s*<\#(foldedKey)>\#(foldedMark)</\#(foldedKey)>\s*(?=<)"# }

    public func folded(upTo level: Int) -> Self {
        guard level > 0 else {
            if children.isEmpty {
                return copy()
            } else {
                let copy = copyWithoutChildren()
                copy.addChild(ExplorerXML(name: foldedKey, value: foldedMark))
                return copy
            }
        }

        return copyMappingChildren { $0.folded(upTo: level - 1) }
    }

    public func exportFoldedString(upTo level: Int) throws -> String {
        try folded(upTo: level)
            .exportString()
            .replacingOccurrences(of: foldedRegexPattern, with: "...", options: .regularExpression)
    }
}
