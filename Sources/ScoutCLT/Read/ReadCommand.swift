//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation
import Lux
import ScoutCLTCore

struct ReadCommand: PathExplorerInputCommand, ExportCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read a value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c read`")

    // MARK: - Properties

    /// Colorize the output
    var colorise: Bool {
        if color == .forceColor { return true }

        return
            color.colorise
            && csvSeparator == nil
            && !FileHandle.standardOutput.isPiped
    }

    @Option(name: .dataFormat, help: .dataFormat)
    var dataFormat: Scout.DataFormat

    @Argument(help: .readingPath)
    var readingPath: Path?

    @Option(name: .inputFilePath, help: .inputFilePath, completion: .file())
    var inputFilePath: String?

    @Option(name: .outputFilePath, help: .outputFilePath, completion: .file())
    var outputFilePath: String?

    @Flag(help: .colorise)
    var color = ColorFlag.color

    @Option(name: .fold, help: .fold)
    var level: Int?

    @Option(name: .csvSeparator, help: .csvSeparator)
    var csvSeparator: String?

    @Option(name: .export, help: .export)
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws {
        let readingPath = self.readingPath ?? Path()
        var explorer = try pathExplorer.get(readingPath)
        let value = try getValue(from: &explorer)
        let colorInjector = try self.colorInjector(for: exportFormat ?? P.format)

        if value == "" {
            throw RuntimeError.noValueAt(path: readingPath.description)
        }

        if let output = outputFilePath?.replacingTilde, let contents = value.data(using: .utf8) {
            FileManager.default.createFile(atPath: output, contents: contents, attributes: nil)
            return
        }

        let output = colorise ? colorInjector.inject(in: value) : value
        print(output)
    }

    func getValue<Explorer: SerializablePathExplorer>(from explorer: inout Explorer) throws -> String {

        switch try exportOption() {

        case .csv(let separator):
            return try explorer.exportCSV(separator: separator)

        case .dataFormat(let format):
            return try explorer.exportString(to: format, rootName: fileName(of: inputFilePath))

        case .noExport:
            break
        }

        if explorer.isSingle {
            return explorer.description
        } else if let level = level, outputFilePath == nil { // ignore folding when writing in a file
            return try explorer.exportFoldedString(upTo: level)
        } else {
            return try explorer.exportString()
        }
    }

    func validate() throws {
        if let level = level, level < 0 {
            throw ValidationError(message: "The level to fold the data with the -l|--level option should be greater than 0")
        }
    }
}
