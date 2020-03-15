import ArgumentParser
import Scout
import Foundation

struct SetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "set", abstract: "Change a value at a given path")

    struct PathAndValue: ExpressibleByArgument {
        let readingPath: Path
        let value: String

        init?(argument: String) {
            let splitted = argument.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard
                splitted.count == 2,
                let readingPath = Path(argument: String(splitted[0]))
            else {
                return nil
            }

            self.readingPath = readingPath
            value = String(splitted[1])
        }
    }

    @Argument()
    var pathsAndValues: [PathAndValue]

    @Option(name: [.short, .long], help: "A file path from which read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    func run() throws {

        if let filePath = inputFilePath {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
            try set(from: data)
        } else {
            let streamInput = FileHandle.standardInput.readDataToEndOfFile()
            try set(from: streamInput)
        }
    }

    func set(from data: Data) throws {

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {
            try pathsAndValues.forEach { try json.set($0.readingPath, to: $0.value) }
            try outputDataWith(json)
        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try pathsAndValues.forEach { try plist.set($0.readingPath, to: $0.value) }
            try outputDataWith(plist)
        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try pathsAndValues.forEach { try xml.set($0.readingPath, to: $0.value) }
            try outputDataWith(xml)
        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func outputDataWith<T: PathExplorer>(_ pathExplorer: T) throws {
        if let output = output?.replacingTilde {
            let fm = FileManager.default
            try fm.createFile(atPath: output, contents: pathExplorer.exportData(), attributes: nil)
        } else {
            print(try pathExplorer.exportString())
        }
    }
}

