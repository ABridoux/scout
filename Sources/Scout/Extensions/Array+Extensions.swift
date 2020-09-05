//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Array {

    func getIfPresent(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }

        return self[index]
    }

    func remove(in range: ClosedRange<Int>) -> Self {
        assert(range.lowerBound >= 0)
        assert(range.upperBound < count)

        let leftPart = self[0..<range.lowerBound]
        if range.upperBound < count - 1 {
            let rightPart = self[range.upperBound + 1...count - 1]
            return Array(leftPart + rightPart)
        } else {
            return Array(leftPart)
        }
    }
}
