//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import ScoutCLTCore

struct AddCommand: SADCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c add`")

    // MARK: - Properties

    @Option(name: .dataFormat, help: .dataFormat)
    var dataFormat: Scout.DataFormat

    @Argument(help: PathAndValue.help)
    var pathsCollection = [PathAndValue]()

    @Option(name: .inputFilePath, help: .inputFilePath, completion: .file())
    var inputFilePath: String?

    @Option(name: .outputFilePath, help: .outputFilePath, completion: .file())
    var outputFilePath: String?

    @Option(name: .modifyFilePath, help: .modifyFilePath, completion: .file())
    var modifyFilePath: String?

    @Flag(help: .colorise)
    var color = ColorFlag.color

    @Option(name: .fold, help: .fold)
    var level: Int?

    @Option(name: .csvSeparator, help: .csvSeparator)
    var csvSeparator: String?

    @Option(name: .export, help: .export)
    var exportFormat: ExportFormat?

    // MARK: - Functions

    func perform<P: PathExplorer>(pathExplorer: inout P, pathAndValue: PathAndValue) throws {
        let (path, value) = (pathAndValue.readingPath, pathAndValue.value)
        try pathExplorer.add(value, at: path)
    }
}
