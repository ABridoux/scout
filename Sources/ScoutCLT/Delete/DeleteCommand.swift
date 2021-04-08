//
// Scout
// Copyright (c) Alexis Bridoux 2020
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

    @Argument(help: "Paths to indicate the keys to be deleted")
    var pathsCollection = [Path]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .customLong("output")], help: "Write the modified data into the file at the given path", completion: .file())
    var outputFilePath: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path", completion: .file())
    var modifyFilePath: String?

    @Flag(help: "Highlight the ouput. --no-color or --nc to prevent it")
    var color = ColorFlag.color

    @Option(name: [.short, .long], help: "Fold the data at the given depth level")
    var level: Int?

    @Flag(name: [.short, .long], help: "When the deleted value leaves the array or dictionary holding it empty, delete it too")
    var recursive = false

    @Flag(name: [.customLong("csv")], help: "Convert the array data into CSV with the standard separator ';'")
    var csv = false

    @Option(name: [.customLong("csv-sep")], help: "Convert the array data into CSV with the given separator")
    var csvSeparator: String?

    @Option(name: [.short, .customLong("export")], help: "Convert the data to the specified format")
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func perform<P: SerializablePathExplorer>(pathExplorer: inout P, pathCollectionElement: Path) throws {
        try pathExplorer.delete(pathCollectionElement, deleteIfEmpty: recursive)
    }
}
