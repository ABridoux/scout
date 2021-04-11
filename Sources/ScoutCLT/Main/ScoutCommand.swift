//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser
import Lux

protocol ScoutCommand: ParsableCommand {

    /// A file path from which to read the data
    var inputFilePath: String? { get }

    /// A file path from which to read and write the data
    var modifyFilePath: String? { get }

    var dataFormat: Scout.DataFormat { get }

    /// Called with the correct `PathExplorer` when `inferPathExplorer(from:in:)` completes
    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws
}

extension ScoutCommand {

    // MARK: - Properties

    var modifyFilePath: String? { nil }

    // MARK: - Functions

    func run() throws {
        var filePath: String?
        switch (inputFilePath?.replacingTilde, modifyFilePath?.replacingTilde) {
        case (.some(let path), nil): filePath = path
        case (nil, .some(let path)): filePath = path
        case (nil, nil): break
        case (.some, .some): throw RuntimeError.invalidArgumentsCombination(description: "Combining (-i|--input) with (-m|--modify) is not allowed")
        }

        let data = try readDataOrInputStream(from: filePath)
        try makePathExplorer(for: dataFormat, from: data)
    }

    /// Try to read data from the optional `filePath`. Otherwise, return the data from the standard input stream
    func readDataOrInputStream(from filePath: String?) throws -> Data {
        if let filePath = filePath {
            return try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
        }

        // The function `readDataToEndOfFile()` was deprecated since macOS 10.15.4
        // but now (macOS 11.2.2) it seems to be deprecated for never (100_000)).
        return FileHandle.standardInput.readDataToEndOfFile()

//        return try input.data(using: .utf8)
//            .unwrapOrThrow(error: .invalidData("Unable to get data from standard input"))

//        if #available(OSX 10.15.4, *) {
//            do {
//                return try FileHandle
//                    .standardInput
//                    .readToEnd()
//                    .unwrapOrThrow(error: .invalidData("Unable to get data from standard input"))
//                }
//                return standardInputData
//            } catch {
//                throw RuntimeError.invalidData("Error while reading data from standard input. \(error.localizedDescription)")
//            }
//        } else {
//            return FileHandle.standardInput.readDataToEndOfFile()
//        }
    }

    private func makeExplorer<P: SerializablePathExplorer>(_ type: P.Type, from data: Data) throws -> P {
        do {
            return try P(data: data)
        } catch {
            throw RuntimeError.unknownFormat("The input cannot be read as \(dataFormat).\n\(error.localizedDescription)")
        }
    }

    func makePathExplorer(for dataFormat: Scout.DataFormat, from data: Data) throws {
        switch dataFormat {
        case .json:
            let json = try makeExplorer(Json.self, from: data)
            try inferred(pathExplorer: json)
        case .plist:
            let plist = try makeExplorer(Plist.self, from: data)
            try inferred(pathExplorer: plist)
        case .yaml:
            let yaml = try makeExplorer(Yaml.self, from: data)
            try inferred(pathExplorer: yaml)
        case .xml:
            let xml = try makeExplorer(Xml.self, from: data)
            try inferred(pathExplorer: xml)
        }
    }

    @available(*, deprecated, message: "Useless with the new required dataFormat flag.")
    func inferPathExplorer(from data: Data, in inputFilePath: String?) throws {

        if let json = try? Json(data: data) {
            try inferred(pathExplorer: json)
        } else if let plist = try? Plist(data: data) {
            try inferred(pathExplorer: plist)
        } else if let yaml = try? Yaml(data: data) {
            try inferred(pathExplorer: yaml)
        } else if let xml = try? Xml(data: data) {
            try inferred(pathExplorer: xml)
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
