import Foundation
import ArgumentParser
import Scout

private let abstract =
"""
Read and set values in specific format file or data. Currently supported: Json, Plist and Xml.
"""

private let discussion =
"""
To indicate what value to read or to set, a path should be indicated. A path is a serie of key names or indexes separated by '->' to target one value.
It looks like this "firt_key->second_key->[second_index]->third_key".

Notes
-----
- An index is indicated between squared brackets, like this [5]
- When reading a value, the output is always a string

Given the following Json

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

Here are some example paths:
- Tom first hobby: "people->Tom->hobbies->[0]" = cooking
- Arnaud height: "people->Arnaud->height" = 180
"""

struct ScoutCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
            commandName: "scout",
            abstract: abstract,
            discussion: discussion,
            subcommands: [ReadCommand.self, SetCommand.self, DeleteCommand.self],
            defaultSubcommand: ReadCommand.self)

    static func output<T: PathExplorer>(_ output: String?, dataWith pathExplorer: T) throws {
        if let output = output?.replacingTilde {
            let fm = FileManager.default
            try fm.createFile(atPath: output, contents: pathExplorer.exportData(), attributes: nil)
        } else {
            print(try pathExplorer.exportString())
        }
    }
}
