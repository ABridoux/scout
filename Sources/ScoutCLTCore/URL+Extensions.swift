//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension URL {

    var lastPathComponentWithoutExtension: String {
        let splitted = lastPathComponent.split(separator: ".")

        guard splitted.count > 1 else {
            return lastPathComponent
        }

        return String(splitted[splitted .count - 2])
    }
}
