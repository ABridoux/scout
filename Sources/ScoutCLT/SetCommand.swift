import ArgumentParser
import Scout
import Foundation

struct SetCommand: ParsableCommand {
    static let configuration = CommandConfiguration(commandName: "set", abstract: "Change a value at a given path")

    struct PathAndValue: ExpressibleByArgument {
        let readingPath: Path
        let value: String

        /// Set to `true` when the value is a key name to change. A key name will be indicated with sharps #KeyName#
        let changeKey: Bool

        init?(argument: String) {
            let splitted = argument.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: true)
            guard
                splitted.count == 2,
                let readingPath = Path(argument: String(splitted[0]))
            else {
                return nil
            }

            self.readingPath = readingPath

            var value = String(splitted[1])
            if value.hasPrefix("#"), value.hasSuffix("#") {
                value.removeFirst()
                value.removeLast()
                self.value = value
                changeKey = true
            } else {
                self.value = value
                changeKey = false
            }
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
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try json.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try json.set($0.readingPath, to: $0.value)
                }
            }

            try outputDataWith(json)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try plist.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try plist.set($0.readingPath, to: $0.value)
                }
            }

            try outputDataWith(plist)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {
            try pathsAndValues.forEach {
                if $0.changeKey {
                    try xml.set($0.readingPath, keyNameTo: $0.value)
                } else {
                    try xml.set($0.readingPath, to: $0.value)
                }
            }

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

