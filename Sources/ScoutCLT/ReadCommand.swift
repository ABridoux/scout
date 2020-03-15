import ArgumentParser
import Scout
import Foundation

struct ReadCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(commandName: "read", abstract: "Read a value at a given path. See the discussion to know how to use paths.")

    // MARK: - Properties

    @Argument()
    var readingPath: Path

    @Option(name: [.short, .long], help: "A file path from which read the data")
    var inputFilePath: String?

    // MARK: - Functions

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try read(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try read(from: streamInput)
        }
    }

    func read(from data: Data) throws {
        var value: String

        if let json = try? PathExplorerFactory.make(Json.self, from: data) {
            value = try json.get(readingPath).stringValue
        } else if let plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            value = try plist.get(readingPath).stringValue
        } else if let xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            value = try xml.get(readingPath).stringValue
        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }

        if value == "" {
            throw RuntimeError.noValueAt(path: readingPath.description)
        }

        print(value)
    }
}
