//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation
import Scout
import ArgumentParser

extension PathsFilter.ValueTarget: EnumerableFlag {}

struct PathsCommand: ScoutCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "paths",
        abstract: "List the paths in the data",
        discussion: "To find examples and advanced explanations, please type `scout doc -c paths`")

    // MARK: - Properties

    @Argument(help: .readingPath)
    var readingPath: Path?

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .customLong("key")], help: "Specify a regular expression to filter the keys")
    var keyRegexPattern: String?

    @Flag(help: "")
    var valueTarget = PathsFilter.ValueTarget.singleAndGroup

    // MARK: - Functions

    func inferred<P>(pathExplorer: P) throws where P: PathExplorer {
        var pathsFilter = PathsFilter.targetOnly(valueTarget)

        if let keyRegexPattern = keyRegexPattern {
            guard let regex = try? NSRegularExpression(pattern: keyRegexPattern) else {
                throw RuntimeError.invalidRegex(keyRegexPattern)
            }
            pathsFilter = .key(regex: regex, target: valueTarget)
        }

        let readingPath = self.readingPath ?? Path()
        let paths = try pathExplorer.listPaths(startingAt: readingPath, filter: pathsFilter)

        paths.forEach { print($0.flattened()) }
    }
}
