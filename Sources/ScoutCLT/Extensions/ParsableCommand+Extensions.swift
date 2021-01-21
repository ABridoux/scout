//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser

extension ParsableCommand {

    /// Try to read data from the optional `filePath`. Otherwise, return the data from the standard input stream
    func readDataOrInputStream(from filePath: String?) throws -> Data {
        if let filePath = filePath {
            return try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
        } else {
            return FileHandle.standardInput.readDataToEndOfFile()
        }
    }
}

extension URL {

    var lastPathComponentWithoutExtension: String {
        let splitted = lastPathComponent.split(separator: ".")

        guard splitted.count > 1 else {
            return lastPathComponent
        }

        return String(splitted[splitted .count - 2])
    }
}
