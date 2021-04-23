//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout

private let abstract =
"""
Read and modify values in specific format file or data. Currently supported: Json, Plist, YAML and Xml.
"""

private let discussion =
"""
To find advanced help and rich examples, please type `scout doc`.


Written by Alexis Bridoux. Copyright (c) 2020-present.
\u{001B}[38;5;88mhttps://www.woodys-findings.com/scout\u{001B}[0;0m
MIT license, see LICENSE file for details
"""

struct ScoutMainCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
            commandName: "scout",
            abstract: abstract,
            discussion: discussion,
            version: ScoutVersion.current,
            subcommands: [
                ReadCommand.self,
                SetCommand.self,
                DeleteCommand.self,
                AddCommand.self,
                DocCommand.self,
                PathsCommand.self,
                CSVCommand.self,
                InstallCompletionScriptCommand.self],
            defaultSubcommand: ReadCommand.self)
}
