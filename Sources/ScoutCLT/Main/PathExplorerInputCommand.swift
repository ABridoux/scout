//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser

/// Try to get a PathExplorer from the input
protocol PathExplorerInputCommand: ParsableCommand {

    /// A file path from which to read the data
    var inputFilePath: String? { get }

    /// A file path from which to read and write the data
    var modifyFilePath: String? { get }

    var dataFormat: Scout.DataFormat { get }

    /// Called with the correct `PathExplorer` when `inferPathExplorer(from:in:)` completes
    func inferred<P: SerializablePathExplorer>(pathExplorer: P) throws
}

extension PathExplorerInputCommand {

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

    /// Try to get the regex from the pattern, throwing a `RuntimeError` when failing
    func regexFrom(pattern: String) throws -> NSRegularExpression {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw RuntimeError.invalidRegex(pattern)
        }
        return regex
    }
}
