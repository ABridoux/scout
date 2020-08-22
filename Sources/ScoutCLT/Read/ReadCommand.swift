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

    @Option(name: [.short, .long], help: "Fold the data at the given depth level")
    var level: Int?

    @Option(name: [.customLong("csv")], help: "Convert the array data into CSV")
    var csvSeparator: String?

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

            let output = color && csvSeparator == nil ? injector.inject(in: value) : value
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
            var json = try json.get(path)
//            if let level = level {
//                json.fold(upTo: level)
//            }
//            value = json.stringValue != "" ? json.stringValue : json.description

            value = try getValue(from: &json)

            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector

        } else if let plist = try? Plist(data: data) {
            var plist = try plist.get(path)
//            if let level = level {
//                plist.fold(upTo: level)
//            }
//            value = plist.stringValue != "" ? plist.stringValue : plist.description

            value = try getValue(from: &plist)

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            injector = plistInjector

        } else if let xml = try? Xml(data: data) {
            var xml = try xml.get(path)
//            if let level = level {
//                xml.fold(upTo: level)
//            }
//            value = xml.stringValue != "" ? xml.stringValue : xml.description

            value = try getValue(from: &xml)

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

    func getValue<Explorer: PathExplorer>(from explorer: inout Explorer) throws -> String {
        let value: String

        if let separator = csvSeparator {
            value = try explorer.exportCSV(separator: separator)
            return value
        }

        if let level = level {
            explorer.fold(upTo: level)
        }

        value = explorer.stringValue != "" ? explorer.stringValue : explorer.description

        return value
    }
}
