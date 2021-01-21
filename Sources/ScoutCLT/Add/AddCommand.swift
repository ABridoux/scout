//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation

struct AddCommand: SADCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c add`")

    // MARK: - Properties

    @Argument(help: PathAndValue.help)
    var pathsCollection = [PathAndValue]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path", completion: .file())
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path", completion: .file())
    var modifyFilePath: String?

    @Flag(help: "Highlight the ouput. --no-color or --nc to prevent it")
    var color = ColorFlag.color

    @Option(name: [.short, .long], help: "Fold the data at the given depth level")
    var level: Int?

    @Flag(name: [.customLong("csv")], help: "Convert the array data into CSV with the standard separator ';'")
    var csv = false

    @Option(name: [.customLong("csv-sep")], help: "Convert the array data into CSV with the given separator")
    var csvSeparator: String?

    @Option(name: [.short, .customLong("export")], help: "Convert the data to the specified format")
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func perform<P: PathExplorer>(pathExplorer: inout P, pathCollectionElement: PathAndValue) throws {
        let (path, value) = (pathCollectionElement.readingPath, pathCollectionElement.value)

        if let forceType = pathCollectionElement.forceType {
            switch forceType {
            case .string: try pathExplorer.add(value, at: path, as: .string)
            case .real: try pathExplorer.add(value, at: path, as: .real)
            case .int: try pathExplorer.add(value, at: path, as: .int)
            case .bool: try pathExplorer.add(value, at: path, as: .bool)
            }
        } else {
            try pathExplorer.add(value, at: path)
        }
    }
}
