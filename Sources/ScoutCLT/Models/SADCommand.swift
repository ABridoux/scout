//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation

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
            try ScoutCommand.output(output, dataWith: json, colorise: colorise, level: level, csvSeparator: separator)

        } else if var plist = try? Plist(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &plist, pathCollectionElement: $0) }
            try ScoutCommand.output(output, dataWith: plist, colorise: colorise, level: level, csvSeparator: separator)

        } else if var yaml = try? Yaml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &yaml, pathCollectionElement: $0) }
            try ScoutCommand.output(output, dataWith: yaml, colorise: colorise, level: level, csvSeparator: separator)

        } else if var xml = try? Xml(data: data) {
            try pathsCollection.forEach { try perform(pathExplorer: &xml, pathCollectionElement: $0) }
            try ScoutCommand.output(output, dataWith: xml, colorise: colorise, level: level, csvSeparator: separator)

        } else {

            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}
