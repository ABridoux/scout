//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
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
