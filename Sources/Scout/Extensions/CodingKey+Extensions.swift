//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension CodingKey {

    /// Path element string description
    var pathDescription: String {
        let split = stringValue.components(separatedBy: " ")

        if split.count == 2, split[0] == "Index", let index = Int(split[1]) {
            return "[\(index)]"
        } else {
            return stringValue
        }
    }
}

extension Array where Element == CodingKey {

    /// String description of the coding path
    var pathDescription: String {
        var path = reduce("") { "\($0)\($1.pathDescription)" }

        if path.hasPrefix(".") {
            path.removeFirst()
        }

        return path
    }
}
