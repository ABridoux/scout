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

    @Flag(help: "The data format to read the input")
    var dataFormat: DataFormat

    @Argument(help: "Initial path from which the paths should be listed")
    var initialPath: Path?

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data", completion: .file())
    var inputFilePath: String?

    @Option(name: [.short, .customLong("key")], help: "Specify a regular expression to filter the keys")
    var keyRegexPattern: String?

    @Option(name: [.short, .customLong("value")], help: "Specify a predicate to filter the values of the paths. Several predicates can be specified. A value validated by any of the predicates will be valid.")
    var valuePredicates = [String]()

    @Flag(help: "Target single values (string, number, bool), group values (array, dictionary), or both.")
    var valueTarget = PathsFilter.ValueTarget.singleAndGroup

    // MARK: - Functions

    func inferred<P>(pathExplorer: P) throws where P: PathExplorerBis {
        var pathsFilter = PathsFilter.targetOnly(valueTarget)
        let valuePredicates = self.valuePredicates.isEmpty ? nil : try self.valuePredicates.map { try PathsFilter.ExpressionPredicate(format: $0) }
        var keyRegex: NSRegularExpression?

        if let pattern = keyRegexPattern {
            keyRegex = try regexFrom(pattern: pattern)
        }

        switch (keyRegex, valuePredicates, valueTarget) {

        case (nil, nil, let target):
            pathsFilter = .targetOnly(target)

        case (.some(let regex), nil, let target):
            pathsFilter = .key(regex: regex, target: target)

        case (.some(let regex), .some(let predicates), nil):
            pathsFilter = .keyAndValue(keyRegex: regex, valuePredicates: predicates)

        case (nil, .some(let predicates), nil):
            pathsFilter = .value(predicates)

        case (nil, .some(let predicates), let target):
            if target != .singleAndGroup {
                throw RuntimeError.invalidArgumentsCombination(description: "Using the target flag is not allowed with the (--value|-v) option. Consider removing '--\(target.rawValue)'")
            }
            pathsFilter = .value(predicates)

        case (.some(let regex), .some(let predicates), let target):
            if target != .singleAndGroup {
                throw RuntimeError.invalidArgumentsCombination(description: "Using the target flag is not allowed with the (--value|-v) option. Consider removing '--\(target.rawValue)'")
            }
            pathsFilter = .keyAndValue(keyRegex: regex, valuePredicates: predicates)
        }

        let paths = try pathExplorer.listPaths(startingAt: initialPath, filter: pathsFilter).sortedByKeysAndIndexes()

        paths.forEach { print($0.flattened()) }
    }
}
