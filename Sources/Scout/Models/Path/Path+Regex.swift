//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Path {

    public static let defaultSeparator = "."

    private static let forbiddenSeparators: Set<String> = ["[", "]", "(", ")"]

    static func validate(separator: String) throws {
        if forbiddenSeparators.contains(separator) {
            throw PathError.invalidSeparator(separator)
        }
    }
}
