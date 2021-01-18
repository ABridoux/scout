//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation
import Lux

/// A Set/Add/Delete command for default implementations
protocol SADCommand: ParsableCommand {

    associatedtype PathCollection: Collection

    var pathsCollection: PathCollection { get }
    var output: String? { get }

    var color: ColorFlag { get }
    var level: Int? { get }

    var modifyFilePath: String? { get }
    var inputFilePath: String? { get }

    var csv: Bool { get }
    var csvSeparator: String? { get }

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
        let data = try readDataOrInputStream(from: modifyFilePath ?? inputFilePath)
        let output = modifyFilePath ?? self.output
        let separator = csvSeparator ?? (csv ? ";" : nil)

        if var json = try? Json(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &json, pathCollectionElement: $0) }
            try printOutput(output, dataWith: json, colorise: colorise, level: level, csvSeparator: separator)

        } else if var plist = try? Plist(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &plist, pathCollectionElement: $0) }
            try printOutput(output, dataWith: plist, colorise: colorise, level: level, csvSeparator: separator)

        } else if var yaml = try? Yaml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &yaml, pathCollectionElement: $0) }
            try printOutput(output, dataWith: yaml, colorise: colorise, level: level, csvSeparator: separator)

        } else if var xml = try? Xml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &xml, pathCollectionElement: $0) }
            try printOutput(output, dataWith: xml, colorise: colorise, level: level, csvSeparator: separator)

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
    func printOutput<P: PathExplorer>(_ output: String?, dataWith pathExplorer: P, colorise: Bool, level: Int? = nil, csvSeparator: String? = nil) throws {

        var csv: String?
        if let separator = csvSeparator {
            csv = try pathExplorer.exportCSV(separator: separator)
        }

        // write the output in a file
        if let output = output?.replacingTilde {
            let fm = FileManager.default
            let contents = try csv?.data(using: .utf8) ?? pathExplorer.exportData()
            fm.createFile(atPath: output, contents: contents, attributes: nil)
            return
        }

        // write the output in the terminal

        if let csvOutput = csv {
            print(csvOutput)
            return
        }

        // shadow variable to fold if necessary
        var pathExplorer = pathExplorer

        // fold if specified
        if let level = level {
            pathExplorer.fold(upTo: level)
        }

        let output = try pathExplorer.exportString()

        if colorise {
            try coloriseAndPrint(output: output, with: pathExplorer)
        } else {
            print(output)
        }
    }

    func coloriseAndPrint<P: PathExplorer>(output: String, with pathExplorer: P) throws {
        let injector: TextInjector

        switch pathExplorer.format {

        case .json:
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector

        case .plist:

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            injector = plistInjector

        case .xml:
            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            injector = xmlInjector

        case .yaml:
            #warning("[TODO] Change for a YAML color injector")
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector
        }

        print(injector.inject(in: output))
    }
}
