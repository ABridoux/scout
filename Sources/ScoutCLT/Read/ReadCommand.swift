//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation
import Lux

struct ReadCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read a value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c read`")

    // MARK: - Properties

    @Argument(help: .readingPath)
    var readingPath: Path?

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Flag(name: [.long], inversion: .prefixedNo, help: "Colorise the ouput")
    var color = true

    // MARK: - Functions

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try read(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try read(from: streamInput)
        }
    }

    func read(from data: Data) throws {

        let readingPath = self.readingPath ?? Path()

        do {
            let (value, injector) = try readValue(at: readingPath, in: data)

            if value == "" {
                throw RuntimeError.noValueAt(path: readingPath.description)
            }

            let output = color ? injector.inject(in: value) : value
            print(output)
        }
    }

    /// - Parameters:
    ///   - path: The path of the value to output
    ///   - data: The data where to search for the value
    /// - Throws: If the path is invalid or the values does not exist
    /// - Returns: The value, and the corresponding
    func readValue(at path: Path, in data: Data) throws -> (value: String, injector: TextInjector) {

        var injector: TextInjector
        var value: String

        if let json = try? Json(data: data) {
            let key = try json.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector

        } else if let plist = try? Plist(data: data) {
            let key = try plist.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            injector = plistInjector

        } else if let xml = try? Xml(data: data) {
            let key = try xml.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            injector = xmlInjector

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }

        return (value, injector)
    }
}
