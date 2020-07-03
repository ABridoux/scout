import ArgumentParser
import Scout
import Foundation

struct SetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "set",
        abstract: "Change a value at a given path.",
        discussion: "To find examples and advanced explanations, please type `scout doc set`")

    @Argument(help: PathAndValue.help)
    var pathsAndValues = [PathAndValue]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path")
    var modifyFilePath: String?

    @Flag(name: [.short, .long], inversion: .prefixedNo, help: "Output the modified data")
    var verbose = false

    func run() throws {

        do {
            if let filePath = modifyFilePath ?? inputFilePath {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
                try set(from: data)
            } else {
                let streamInput = FileHandle.standardInput.readDataToEndOfFile()
                try set(from: streamInput)
            }
        } catch let error as PathExplorerError {
            print(error.commandLineErrorDescription)
            return
        }
    }

    func set(from data: Data) throws {
        let output = modifyFilePath ?? self.output

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {

            try set(pathsAndValues, in: &json)
            try ScoutCommand.output(output, dataWith: json, verbose: verbose)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {

            try set(pathsAndValues, in: &plist)
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {

            try set(pathsAndValues, in: &xml)
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func set<Explorer: PathExplorer>(_ pathAndValues: [PathAndValue], in explorer: inout Explorer) throws {
        for pathAndValue in pathAndValues {
            let (path, value) = (pathAndValue.readingPath, pathAndValue.value)

            if pathAndValue.changeKey {
                try explorer.set(path, keyNameTo: value)
                continue
            }

            if let forceType = pathAndValue.forceType {
                switch forceType {
                case .string: try explorer.set(path, to: value, as: .string)
                case .real: try explorer.set(path, to: value, as: .real)
                case .int: try explorer.set(path, to: value, as: .int)
                case .bool: try explorer.set(path, to: value, as: .bool)
                }
            } else {
                try explorer.set(path, to: value)
            }
        }
    }
}
