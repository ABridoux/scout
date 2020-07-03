import ArgumentParser
import Scout
import Foundation
import Lux

struct ReadCommand: ParsableCommand {

    // MARK: - Constants

    static let configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Read a value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc read`")

    // MARK: - Properties

    @Argument(help: "Path in the data where to read the key value")
    var readingPath: Path?

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
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

        let readingPath = self.readingPath ?? Path()

        do {
            let (value, injector) = try readValue(at: readingPath, in: data)

            if value == "" {
                throw RuntimeError.noValueAt(path: readingPath.description)
            }

            let output = injector.inject(in: value)
            print(output)

        } catch let error as PathExplorerError {
            print(error.commandLineErrorDescription)
            return
        }
    }

    func readValue(at path: Path, in data: Data) throws -> (value: String, injector: TextInjector) {

        var injector: TextInjector
        var value: String

        if let json = try? PathExplorerFactory.make(Json.self, from: data) {
            let key = try json.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let jsonInjector = JSONInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.json {
                jsonInjector.delegate = JSONInjectorColorDelegate(colors: colors)
            }
            injector = jsonInjector

        } else if let plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            let key = try plist.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let plistInjector = PlistInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.plist {
                plistInjector.delegate = PlistInjectorColorDelegate(colors: colors)
            }
            injector = plistInjector

        } else if let xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            let key = try xml.get(path)
            value = key.stringValue != "" ? key.stringValue : key.description

            let xmlInjector = XMLEnhancedInjector(type: .terminal)
            if let colors = try ScoutCommand.getColorFile()?.xml {
                xmlInjector.delegate = XMLInjectorColorDelegate(colors: colors)
            }
            injector = xmlInjector

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }

        return (value, injector)
    }
}
