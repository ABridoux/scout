//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation
import Lux
import ScoutCLTCore

/// A Set/Add/Delete command for default implementations
protocol SADCommand: ScoutCommand, ExportCommand {

    associatedtype PathCollection: Collection

    var pathsCollection: PathCollection { get }

    var color: ColorFlag { get }
    var level: Int? { get }

    var modifyFilePath: String? { get }
    var outputFilePath: String? { get }

    /// Executed for each `pathsCollection` element
    func perform<P: SerializablePathExplorer>(pathExplorer: inout P, pathCollectionElement: PathCollection.Element) throws
}

extension SADCommand {

    /// Colorize the output
    var colorise: Bool {
        if color == .forceColor { return true }

        return
            color.colorise
            && csvSeparator == nil
            && csv == false
            && !FileHandle.standardOutput.isPiped
    }

    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws {
        let outputPath = modifyFilePath?.replacingTilde ?? outputFilePath?.replacingTilde

        var explorer = pathExplorer
        try pathsCollection.forEach { try perform(pathExplorer: &explorer, pathCollectionElement: $0) }
        try printOutput(outputPath, dataWith: explorer, colorise: colorise, level: level)
    }
}

extension SADCommand {

    /// Print the data from the path explorer and colorize it if specified
    /// - Parameters:
    ///   - outputFilePath: A file path to a file where to write the data
    ///   - pathExplorer: The path explorer to use to get the data
    ///   - colorise: `true` if the data should be colorised
    ///   - level: The level to fold the data
    ///   - csvSeparator: The csv separator to use to export the data
    func printOutput<P: SerializablePathExplorer>(_ outputFilePath: String?, dataWith pathExplorer: P, colorise: Bool, level: Int? = nil) throws {

        if let output = outputFilePath?.replacingTilde {
            FileManager.default.createFile(atPath: output, contents: nil, attributes: nil)
        }

        switch try export() {
        case .csv(let separator):
            let csv = try pathExplorer.exportCSV(separator: separator)
            if let output = outputFilePath {
                try csv.write(toFile: output, atomically: false, encoding: .utf8)
            } else {
                print(csv)
            }
            return

        case .dataFormat(let format):
            let exported = try pathExplorer.exportData(to: format, rootName: fileName(of: inputFilePath))
            if let output = outputFilePath {
                try exported.write(to: URL(fileURLWithPath: output))
            } else {
                guard let string = String(data: exported, encoding: .utf8) else {
                    throw SerializationError.dataToString
                }
                try printOutput(output: string, with: format)
            }
            return

        case nil:
            break
        }

        // fold if specified
        let output: String

        if let level = level {
            output = try pathExplorer.exportFoldedString(upTo: level)
        } else {
            output = try pathExplorer.exportString()
        }

        if let filePath = outputFilePath {
            try output.write(toFile: filePath, atomically: false, encoding: .utf8)
        } else {
            try printOutput(output: output, with: P.format)
        }
    }

    func printOutput(output: String, with format: Scout.DataFormat) throws {
        if colorise {
            let injector = try colorInjector(for: format)
            print(injector.inject(in: output))
        } else {
            print(output)
        }
    }
}
