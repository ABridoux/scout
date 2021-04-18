//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
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

    @Option(name: DataFormat.name)
    var dataFormat: Scout.DataFormat

    @Argument(help: PathAndValue.help)
    var pathsCollection = [PathAndValue]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .customLong("output")], help: "Write the modified data into the file at the given path", completion: .file())
    var outputFilePath: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path", completion: .file())
    var modifyFilePath: String?

    @Flag(help: "Highlight the output. --no-color or --nc to prevent it")
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

        let explorerValue: ExplorerValue

        if let forceType = pathCollectionElement.forceType {

            switch forceType {
            case .string:
                explorerValue = .string(value)

            case .real:
                let double = try Double(value).unwrapOrThrow(.valueConversion(value: value, type: "Double"))
                explorerValue = .double(double)

            case .int:
                let int = try Int(value).unwrapOrThrow(.valueConversion(value: value, type: "Int"))
                explorerValue = .int(int)

            case .bool:
                let bool = try Bool(value).unwrapOrThrow(.valueConversion(value: value, type: "Bool"))
                explorerValue = .bool(bool)
            }
        } else {
            explorerValue = .init(fromSingle: value)
        }

        try pathExplorer.add(explorerValue, at: path)
    }
}
