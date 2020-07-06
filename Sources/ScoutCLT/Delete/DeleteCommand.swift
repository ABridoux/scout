import ArgumentParser
import Scout
import Foundation

struct DeleteCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc delete`")

    // MARK: - Properties

    @Argument(help: "Paths to indicate the keys to be deleted")
    var readingPaths = [Path]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path")
    var modifyFilePath: String?

    @Flag(name: [.short, .long], inversion: .prefixedNo, help: "Output the modified data")
    var verbose = false

    @Flag(name: [.long], inversion: .prefixedNo, help: "Colorise the ouput")
    var color = true

    // MARK: - Functions

    func run() throws {

        do {
            if let filePath = modifyFilePath ?? inputFilePath {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
                try delete(from: data)
            } else {
                let streamInput = FileHandle.standardInput.readDataToEndOfFile()
                try delete(from: streamInput)
            }
        }
    }

    func delete(from data: Data) throws {
        let output = modifyFilePath ?? self.output

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {

            try readingPaths.forEach { try json.delete($0) }
            try ScoutCommand.output(output, dataWith: json, verbose: verbose, colorise: color)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {

            try readingPaths.forEach { try plist.delete($0) }
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose, colorise: color)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {

            try readingPaths.forEach { try xml.delete($0) }
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose, colorise: color)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}
