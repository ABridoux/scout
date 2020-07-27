//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension NSRegularExpression {

    func matches(in string: String) -> [String] {
        let matches = self.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        return matches.map { String(string[$0.range]) }
    }
}
