//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser
import Lux

protocol ScoutCommand: ParsableCommand {

    var inputFilePath: String? { get }

    /// Called with the correct `PathExplorer` when `inferPathExplorer(from:in:)` completes
    func inferred<P: PathExplorer>(pathExplorer: P) throws
}

extension ScoutCommand {

    func run() throws {
        let data = try readDataOrInputStream(from: inputFilePath)
        try inferPathExplorer(from: data, in: inputFilePath)
    }

    /// Try to read data from the optional `filePath`. Otherwise, return the data from the standard input stream
    func readDataOrInputStream(from filePath: String?) throws -> Data {
        if let filePath = filePath {
            return try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
        } else {
            return FileHandle.standardInput.readDataToEndOfFile()
        }
    }

    func inferPathExplorer(from data: Data, in inputFilePath: String?) throws {

        if let json = try? Json(data: data) {
            try inferred(pathExplorer: json)
        } else if let plist = try? Plist(data: data) {
            try inferred(pathExplorer: plist)
        } else if let xml = try? Xml(data: data) {
            try inferred(pathExplorer: xml)
        } else if let yaml = try? Yaml(data: data) {
            try inferred(pathExplorer: yaml)
        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    /// Retrieve the color file to colorise the output if one is found
    func getColorFile() throws -> ColorFile? {
        let colorFileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".scout/Colors.plist")
        guard let data = try? Data(contentsOf: colorFileURL) else { return nil }

        return try PropertyListDecoder().decode(ColorFile.self, from: data)
    }

    func colorInjector(for format: Scout.DataFormat) throws -> TextInjector {
        switch format {

        case .json:
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            return jsonInjector

        case .plist:
            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            return plistInjector

        case .yaml:
            let yamlInjector = YAMLInjector(type: .terminal)
            if let colors = try getColorFile()?.yaml {
                yamlInjector.delegate = YAMLInjectorColorDelegate(colors: colors)
            }
            return yamlInjector

        case .xml:
            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            return xmlInjector
        }
    }

    /// Try to get the regex from the pattern, throwing a `RuntimeError` when failing
    func regexFrom(pattern: String) throws -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw RuntimeError.invalidRegex(pattern)
        }
        return regex
    }
}
