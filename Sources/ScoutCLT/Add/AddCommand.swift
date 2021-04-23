//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Scout
import Foundation

struct AddCommand: SADCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc -c add`")

    // MARK: - Properties

    @Option(name: .dataFormat, help: .dataFormat)
    var dataFormat: Scout.DataFormat

    @Argument(help: PathAndValue.help)
    var pathsCollection = [PathAndValue]()

    @Option(name: .inputFilePath, help: .inputFilePath, completion: .file())
    var inputFilePath: String?

    @Option(name: .outputFilePath, help: .outputFilePath, completion: .file())
    var outputFilePath: String?

    @Option(name: .modifyFilePath, help: .modifyFilePath, completion: .file())
    var modifyFilePath: String?

    @Flag(help: .colorise)
    var color = ColorFlag.color

    @Option(name: .fold, help: .fold)
    var level: Int?

    @Option(name: .csvSeparator, help: .csvSeparator)
    var csvSeparator: String?

    @Option(name: .export, help: .export)
    var exportFormat: Scout.DataFormat?

    // MARK: - Functions

    func perform<P: PathExplorer>(pathExplorer: inout P, pathCollectionElement: PathAndValue) throws {
        let (path, value) = (pathCollectionElement.readingPath, pathCollectionElement.value)

        let explorerValue: ExplorerValue

        if let forceType = pathCollectionElement.forceType {

            switch forceType {
            case .string:
                explorerValue = .string(value)

            case .real:
                let double = try Double(value).unwrapOrThrow(.valueConversion(value: value, type: "Double"))
                explorerValue = .double(double)

            case .int:
                let int = try Int(value).unwrapOrThrow(.valueConversion(value: value, type: "Int"))
                explorerValue = .int(int)

            case .bool:
                let bool = try Bool(value).unwrapOrThrow(.valueConversion(value: value, type: "Bool"))
                explorerValue = .bool(bool)
            }
        } else {
            explorerValue = .init(fromSingle: value)
        }

        try pathExplorer.add(explorerValue, at: path)
    }
}
