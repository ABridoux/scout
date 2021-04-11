//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser

struct DeleteKeyCommand: SADCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "delete-key",
        abstract: "Delete all the (key, value) pairs where the key matches the regular expression pattern",
        discussion: "To find examples and advanced explanations, please type `scout doc -c delete`")

    // MARK: - Properties

    var pathsCollection: [Path] { [Path("empty")] }

    @Flag(help: "The data format to read the input")
    var dataFormat: DataFormat

    @Argument(help: "The regular expression pattern the keys to delete have to match")
    var pattern: String

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
        // postponed to 3.1.0

//         will be called only once
//        guard let regex = try? NSRegularExpression(pattern: pattern) else {
//            throw RuntimeError.invalidRegex(pattern)
//        }
//        try pathExplorer.delete(regularExpression: regex, deleteIfEmpty: recursive)
    }
}
