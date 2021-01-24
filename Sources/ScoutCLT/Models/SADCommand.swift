//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation
import Lux
import ScoutCLTCore

/// A Set/Add/Delete command for default implementations
protocol SADCommand: ParsableCommand, ExportCommand {

    associatedtype PathCollection: Collection

    var pathsCollection: PathCollection { get }

    var color: ColorFlag { get }
    var level: Int? { get }

    var modifyFilePath: String? { get }
    var inputFilePath: String? { get }
    var outputFilePath: String? { get }

    /// Executed for each `pathsCollection` element
    func perform<P: PathExplorer>(pathExplorer: inout P, pathCollectionElement: PathCollection.Element) throws
}

extension SADCommand {

    /// Colorize the output
    var colorise: Bool {
        if color == .forceColor { return true }

        return
            color.colorise
            && csvSeparator == nil
            && csv == false
            && !FileHandle.standardOutput.isPiped
    }

    func run() throws {
        try defaultRun()
    }

    /// The default run function implementation for a SAD command
    func defaultRun() throws {
        let data = try readDataOrInputStream(from: modifyFilePath ?? inputFilePath)
        let outputPath = modifyFilePath ?? outputFilePath

        if var json = try? Json(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &json, pathCollectionElement: $0) }
            try printOutput(outputPath, dataWith: json, colorise: colorise, level: level)

        } else if var plist = try? Plist(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &plist, pathCollectionElement: $0) }
            try printOutput(outputPath, dataWith: plist, colorise: colorise, level: level)

        } else if var yaml = try? Yaml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &yaml, pathCollectionElement: $0) }
            try printOutput(outputPath, dataWith: yaml, colorise: colorise, level: level)

        } else if var xml = try? Xml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &xml, pathCollectionElement: $0) }
            try printOutput(outputPath, dataWith: xml, colorise: colorise, level: level)

        } else {

            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}

extension SADCommand {

    /// Print the data from the path explorer and colorize it if specified
    /// - Parameters:
    ///   - output: A file path to a file where to write the data
    ///   - pathExplorer: The path explorer to use to get the data
    ///   - colorise: `true` if the data should be colorised
    ///   - level: The level to fold the data
    ///   - csvSeparator: The csv separator to use to export the data
    func printOutput<P: PathExplorer>(_ output: String?, dataWith pathExplorer: P, colorise: Bool, level: Int? = nil) throws {

        if let output = output?.replacingTilde {
            FileManager.default.createFile(atPath: output, contents: nil, attributes: nil)
        }

        switch try export() {
        case .csv(let separator):
            let csv = try pathExplorer.exportCSV(separator: separator)
            if let output = output {
                try csv.write(toFile: output, atomically: false, encoding: .utf8)
            } else {
                print(csv)
            }

        case .dataFormat(let format):
            let exported = try pathExplorer.exportDataTo(format, rootName: fileName(of: inputFilePath))
            if let output = output {
                try exported.write(to: URL(fileURLWithPath: output))
            } else {
                guard let string = String(data: exported, encoding: .utf8) else {
                    throw PathExplorerError.dataToStringConversionError
                }
                try printOutput(output: string, with: format)
            }

        case nil:
            break
        }

        // shadow variable to fold if necessary
        var pathExplorer = pathExplorer

        // fold if specified
        if let level = level {
            pathExplorer.fold(upTo: level)
        }

        let output = try pathExplorer.exportString()

        try printOutput(output: output, with: pathExplorer.format)
    }

    func printOutput(output: String, with format: Scout.DataFormat) throws {

        guard colorise else {
            print(output)
            return
        }

        switch format {

        case .json:
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            print(jsonInjector.inject(in: output))

        case .plist:

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            print(plistInjector.inject(in: output))

        case .xml:
            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            print(xmlInjector.inject(in: output))

        case .yaml:
            #warning("[TODO] Change for a YAML color injector")
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            print(jsonInjector.inject(in: output))
        }
    }
}
