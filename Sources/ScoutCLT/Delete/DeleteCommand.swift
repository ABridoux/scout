//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation

struct DeleteCommand: SADCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c delete-key`")

    // MARK: - Properties

    @Option(name: .dataFormat, help: .dataFormat)
    var dataFormat: Scout.DataFormat

    @Argument(help: "Paths to indicate the keys to be deleted")
    var pathsCollection = [Path]()

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

    @Flag(name: [.short, .long], help: "When the deleted value leaves the array or dictionary holding it empty, delete it too")
    var recursive = false

    @Option(name: .csvSeparator, help: .csvSeparator)
    var csvSeparator: String?

    @Option(name: .export, help: .export)
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func perform<P: SerializablePathExplorer>(pathExplorer: inout P, pathCollectionElement: Path) throws {
        try pathExplorer.delete(pathCollectionElement, deleteIfEmpty: recursive)
    }
}
