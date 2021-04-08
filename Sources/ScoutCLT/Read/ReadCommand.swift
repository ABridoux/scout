//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation
import Lux
import ScoutCLTCore

struct ReadCommand: ScoutCommand, ExportCommand {

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
            && csv == false
            && !FileHandle.standardOutput.isPiped
    }

    @Argument(help: .readingPath)
    var readingPath: Path?

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .customLong("output")], help: "Write the read data into the file at the given path", completion: .file())
    var outputFilePath: String?

    @Flag(help: "Highlight the ouput. --no-color or --nc to prevent it")
    var color = ColorFlag.color

    @Option(name: [.short, .long], help: "Fold the data at the given depth level")
    var level: Int?

    @Flag(help: "Convert the array data into CSV with the standard separator ';'")
    var csv = false

    @Option(name: [.customLong("csv-sep")], help: "Convert the array data into CSV with the given separator")
    var csvSeparator: String?

    @Option(name: [.short, .customLong("export")], help: "Convert the data to the specified format")
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws {
        let readingPath = self.readingPath ?? Path()
        var explorer = try pathExplorer.get(readingPath)
        let value = try getValue(from: &explorer)
        let colorInjector = try self.colorInjector(for: exportFormat ?? P.Format.dataFormat)

        if value == "" {
            throw RuntimeError.noValueAt(path: readingPath.description)
        }

        if let output = outputFilePath?.replacingTilde, let contents = value.data(using: .utf8) {
            let fm = FileManager.default
            fm.createFile(atPath: output, contents: contents, attributes: nil)
            return
        }

        let output = colorise ? colorInjector.inject(in: value) : value
        print(output)
    }

    func getValue<Explorer: SerializablePathExplorer>(from explorer: inout Explorer) throws -> String {

        switch try export() {

        case .csv(let separator):
            return try explorer.exportCSV(separator: separator)

        case .dataFormat(let format):
            return try explorer.exportString(to: format, rootName: fileName(of: inputFilePath))

        case nil:
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
}
