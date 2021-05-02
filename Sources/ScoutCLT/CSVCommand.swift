//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser
import ScoutCLTCore

struct CSVCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "csv",
        abstract: "Convert a CSV input in one of the supported format")

    // MARK: - Properties

    @Option(name: [.short, .long], help: "The separator used in the CSV input")
    var separator: String

    @Option(name: .dataFormat, help: .dataFormat)
    var dataFormat: DataFormat

    @Flag(help: "Indicates whether the CSV input has headers and thus should be treated like an array of dictionaries")
    var headers: Headers

    @Option(name: .inputFilePath, help: .inputFilePath, completion: .file())
    var inputFilePath: String?

    @Option(name: .outputFilePath, help: .outputFilePath, completion: .file())
    var outputFilePath: String?

    @Flag(help: .colorise)
    var color = ColorFlag.color

    // MARK: - Functions

    func run() throws {
        let inputData = try readDataOrInputStream(from: inputFilePath)
        let inputString = try String(data: inputData, encoding: .utf8).unwrapOrThrow(.dataToString)
        guard let character = separator.first, separator.count == 1 else {
            throw RuntimeError.custom("Argument 'separator' should be a unique character")
        }

        switch dataFormat {
        case .json:
            let json = try Json.fromCSV(string: inputString, separator: character, hasHeaders: headers == .headers)
            try handleOutput(with: json)

        case .plist:
            let plist = try Plist.fromCSV(string: inputString, separator: character, hasHeaders: headers == .headers)
            try handleOutput(with: plist)

        case .yaml:
            let yaml = try Yaml.fromCSV(string: inputString, separator: character, hasHeaders: headers == .headers)
            try handleOutput(with: yaml)

        case .xml:
            let xml = try Xml.fromCSV(string: inputString, separator: character, hasHeaders: headers == .headers)
            try handleOutput(with: xml)
        }
    }

    func handleOutput<P: SerializablePathExplorer>(with explorer: P) throws {
        if let filePath = outputFilePath {
            let data = try explorer.exportData()
            FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)

        } else {
            var output = try explorer.exportString()
            let highlight = try self.colorInjector(for: dataFormat)
            output = colorise ? highlight(output) : output
            print(output)
        }
    }
}

extension CSVCommand {

    enum Headers: EnumerableFlag {
        case headers
        case noHeaders
    }
}

extension CSVCommand {

    /// Colorize the output
    var colorise: Bool {
        if color == .forceColor { return true }
        return color.colorise && !FileHandle.standardOutput.isPiped
    }
}
