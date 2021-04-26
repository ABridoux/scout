//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation
import Lux
import ScoutCLTCore

/// A Set/Add/Delete command for default implementations
protocol SADCommand: PathExplorerInputCommand, ExportCommand {

    associatedtype PathCollection: Collection

    var pathsCollection: PathCollection { get }

    var color: ColorFlag { get }
    var level: Int? { get }

    var modifyFilePath: String? { get }
    var outputFilePath: String? { get }

    /// Executed for each `pathsCollection` element
    func perform<P: SerializablePathExplorer>(pathExplorer: inout P, pathAndValue: PathCollection.Element) throws
}

extension SADCommand {

    /// Colorize the output
    var colorise: Bool {
        if color == .forceColor { return true }

        return
            color.colorise
            && csvSeparator == nil
            && !FileHandle.standardOutput.isPiped
    }

    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws {
        let outputPath = modifyFilePath?.replacingTilde ?? outputFilePath?.replacingTilde

        var explorer = pathExplorer
        try pathsCollection.forEach { try perform(pathExplorer: &explorer, pathAndValue: $0) }
        try printOutput(outputPath, dataWith: explorer, colorise: colorise, level: level)
    }
}

extension SADCommand {

    /// Print the data from the path explorer and highlight it if specified
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

        switch try exportOption() {
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

        case .array:
            do {
                let array = try pathExplorer.array(of: GroupExportValue.self).map(\.value).joined(separator: " ")
                print("\(array)")

            } catch {
                throw RuntimeError.custom("Unable to represent the value as an array of single elements")
            }

        case .dictionary:
            do {
                let dict = try pathExplorer.dictionary(of: GroupExportValue.self)
                    .map { "\($0.key) \($0.value.value)" }
                    .joined(separator: " ")
                print("\(dict)")

            } catch {
                throw RuntimeError.custom("Unable to represent the value as a dictionary of single elements")
            }

        case .noExport:
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
