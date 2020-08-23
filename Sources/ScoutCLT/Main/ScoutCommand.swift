//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import ArgumentParser
import Scout
import Lux

private let abstract =
"""
Read and modify values in specific format file or data. Currently supported: Json, Plist and Xml.
"""

private let discussion =
"""
To find advanced help and rich examples, please type `scout doc`.


Written by Alexis Bridoux.
\u{001B}[38;5;88mhttps://github.com/ABridoux/scout\u{001B}[0;0m
MIT license, see LICENSE file for details
"""

struct ScoutCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
            commandName: "scout",
            abstract: abstract,
            discussion: discussion,
            version: Scout.Version.current,
            subcommands: [
                ReadCommand.self,
                SetCommand.self,
                DeleteCommand.self,
                AddCommand.self,
                DocCommand.self,
                InstallCompletionScriptCommand.self],
            defaultSubcommand: ReadCommand.self)

    // MARK: - Functions

    static func output<T: PathExplorer>(_ output: String?, dataWith pathExplorer: T, verbose: Bool, colorise: Bool, level: Int? = nil, csv: String? = nil) throws {
        if let output = output?.replacingTilde {
            let fm = FileManager.default
            try fm.createFile(atPath: output, contents: pathExplorer.exportData(), attributes: nil)
        }

        let injector: TextInjector

        switch pathExplorer.format {

        case .json:
            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector

        case .plist:

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            injector = plistInjector

        case .xml:
            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            injector = xmlInjector
        }

        var pathExplorer = pathExplorer

        if let level = level {
            pathExplorer.fold(upTo: level)
        }

        if let separator = csv {
            let output = try pathExplorer.exportCSV(separator: separator)
            print(output)
        } else if verbose {
            var output = try pathExplorer.exportString()
            output = colorise ? injector.inject(in: output) : output
            print(output)
        }
    }

    static func getColorFile() throws -> ColorFile? {
        let colorFileURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".scout/Colors.plist")
        guard let data = try? Data(contentsOf: colorFileURL) else { return nil }

        return try PropertyListDecoder().decode(ColorFile.self, from: data)
    }
}
