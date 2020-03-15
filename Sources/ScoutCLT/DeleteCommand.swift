import ArgumentParser
import Scout
import Foundation

struct DeleteCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(commandName: "delete", abstract: "Delete a value at a given path")

    // MARK: - Properties

    @Argument()
    var readingPath: Path

    @Option(name: [.short, .long], help: "A file path from which read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    // MARK: - Functions

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try delete(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try delete(from: streamInput)
        }
    }

    func delete(from data: Data) throws {

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {
            try json.delete(readingPath)
            try ScoutCommand.output(output, dataWith: json)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try plist.delete(readingPath)
            try ScoutCommand.output(output, dataWith: plist)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try xml.delete(readingPath)
            try ScoutCommand.output(output, dataWith: xml)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }
}
