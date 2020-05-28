import ArgumentParser
import Scout
import Foundation

private let discussion =
"""
Notes
=====
- All the keys which do not exist in the path will be created
- Enclose the value with slash signs to force the value as a string: /valueAsString/ (Plist, Json)
- Enclose the value with interrogative signs to force the value as a boolean: ?valueToBoolean? (Plist, Json)
- Enclose the value with tilde signs to force the value as a real: ~valueToReal~ (Plist)
- Enclose the value with chevron signs to force the value as a integer: <valueToInteger> (Plist)
- When adding an element in an array , use the index -1 to add the element at the end of the array

Examples
========
Given the following Json (as input stream or file)

{
  "people": {
    "Tom": {
      "height": 175,
      "age": 68,
      "hobbies": [
        "cooking",
        "guitar"
      ]
    },
    "Arnaud": {
      "height": 180,
      "age": 23,
      "hobbies": [
        "video games",
        "party",
        "tennis"
      ]
    }
  }
}

`scout add "people.Franklin.height"=165` will create a new dictionary Franklin and add a height key into it with the value 165

`scout add "people.Tom.hobbies[-1]"="Playing music"` will add the hobby "Playing music" to Tom hobbies at the end of the array

`scout add "people.Arnaud.hobbies[1]"=reading` will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party"

`scout add "people.Franklin.hobbies[0]"=football` will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array

`scout add "people.Franklin.height"=/165/` will create a new dictionary Franklin and add a height key into it with the String value "165"

`scout add "people.Franklin.height"=~165~` will create a new dictionary Franklin and add a height key into it with the Real value 165 (Plist only)

More
====
You can find more examples here: https://github.com/ABridoux/scout/tree/master/Playground
"""

struct AddCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path",
        discussion: discussion)

    @Argument(help: PathAndValue.help)
    var pathsAndValues: [PathAndValue]

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path")
    var modifyFilePath: String?

    @Flag(name: [.short, .long], default: false, inversion: .prefixedNo, help: "Output the modified data")
    var verbose: Bool

    func run() throws {

        do {
            if let filePath = modifyFilePath ?? inputFilePath {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
                try add(from: data)
            } else {
                let streamInput = FileHandle.standardInput.readDataToEndOfFile()
                try add(from: streamInput)
            }
        } catch let error as PathExplorerError {
            print(error.commandLineErrorDescription)
            return
        }
    }

    func add(from data: Data) throws {
        let output = modifyFilePath ?? self.output

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {

            try add(pathsAndValues, to: &json)
            try ScoutCommand.output(output, dataWith: json, verbose: verbose)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {

            try add(pathsAndValues, to: &plist)
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {

            try add(pathsAndValues, to: &xml)
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func add<Explorer: PathExplorer>(_ pathsAndValues: [PathAndValue], to explorer: inout Explorer) throws {
        try pathsAndValues.forEach { pathAndValue in
            let (path, value) = (pathAndValue.readingPath, pathAndValue.value)

            if let forceType = pathAndValue.forceType {
                switch forceType {
                case .string: try explorer.add(value, at: path, as: .string)
                case .real: try explorer.add(value, at: path, as: .real)
                case .int: try explorer.add(value, at: path, as: .int)
                case .bool: try explorer.add(value, at: path, as: .bool)
                }
            } else {
                try explorer.add(value, at: path)
            }
        }
    }
}
