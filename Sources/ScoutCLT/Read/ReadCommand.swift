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

    @Option(name: [.short, .long], help: "Write the read data into the file at the given path", completion: .file())
    var output: String?

    @Flag(help: "Highlight the ouput. --no-color or --nc to prevent it")
    var color = ColorFlag.color

    @Option(name: [.short, .long], help: "Fold the data at the given depth level")
    var level: Int?

    @Flag(help: "Convert the array data into CSV with the standard separator ';'")
    var csv = false

    @Option(name: [.customLong("csv-sep")], help: "Convert the array data into CSV with the given separator")
    var csvSeparator: String?

    // MARK: - Functions

    func run() throws {
        let data = try readDataOrInputStream(from: inputFilePath)
        try read(from: data)
    }

    func read(from data: Data) throws {

        let readingPath = self.readingPath ?? Path()

        do {
            let (value, injector) = try readValue(at: readingPath, in: data)

            if value == "" {
                throw RuntimeError.noValueAt(path: readingPath.description)
            }

            if let output = output?.replacingTilde, let contents = value.data(using: .utf8) {
                let fm = FileManager.default
                fm.createFile(atPath: output, contents: contents, attributes: nil)
                return
            }

            let output = colorise ? injector.inject(in: value) : value

            print(output)
        }
    }

    /// - Parameters:
    ///   - path: The path of the value to output
    ///   - data: The data where to search for the value
    /// - Throws: If the path is invalid or the values does not exist
    /// - Returns: The value, and the corresponding
    func readValue(at path: Path, in data: Data) throws -> (value: String, injector: TextInjector) {

        if let json = try? Json(data: data) {
            var json = try json.get(path)

            let value = try getValue(from: &json)

            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }

            return (value, jsonInjector)

        } else if let plist = try? Plist(data: data) {
            var plist = try plist.get(path)

            let value = try getValue(from: &plist)

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }

            return (value, plistInjector)

        } else if let xml = try? Xml(data: data) {
            var xml = try xml.get(path)

            let value = try getValue(from: &xml)

            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }

            return (value, xmlInjector)

        } else if let yaml = try? Yaml(data: data) {
            var yaml = try yaml.get(path)

            let value = try getValue(from: &yaml)

            #warning("[TODO] Change for a YAML color injector")
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }

            return (value, jsonInjector)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func getValue<Explorer: PathExplorer>(from explorer: inout Explorer) throws -> String {
        let value: String

        if let separator = csvSeparator {
            value = try explorer.exportCSV(separator: separator)
            return value
        }

        if csv {
            value = try explorer.exportCSV()
            return value
        }

        if let level = level, output == nil { // ignore folding when writing in a file
            explorer.fold(upTo: level)
        }

        value = explorer.stringValue != "" ? explorer.stringValue : explorer.description

        return value
    }
}
