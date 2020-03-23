import Foundation
import ArgumentParser
import Scout

private let abstract =
"""
Read and modify values in specific format file or data. Currently supported: Json, Plist and Xml.

Written by Alexis Bridoux.
https://github.com/ABridoux/scout
"""

private let discussion =
"""
To indicate what value to target, a path should be indicated. A path is a serie of key names or indexes separated by '.' to target one value.
It looks like this "firt_key.second_key[second_index].third_key".

Notes
=====
- An index is indicated between squared brackets, like this [5]
- When reading a value, the output is always a string

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

Examples
========

Reading
-------
`scout "people.Tom.hobbies[0]"` will output "cooking"
`scout "people.Arnaud.height"` will output "180"
`scout "people.Tom.hobbies[-1]"` will output last Tom hobbies: "guitar"

Setting
-------
`scout set "people.Tom.hobbies[0]"=basket` will change Tom first hobby from "cooking" to "basket"
`scout set "people.Arnaud.height"=160` will change Arnaud's height from 180 to 160
`scout set "people.Tom.age"=#years#` will change Tom age key name from #age# to #years#
`scout set "people.Tom.hobbies[-1]"="playing music"` will change Tom last hobby from "guitar" to "playing music"

Deleting
---------
`scout delete "people.Tom.height"` will delete Tom height
`scout delete "people.Tom.hobbies[0]"` will delete Tom first hobby
`scout delete "people.Tom.hobbies[-1]"` will delete Tom last hobby

Adding
------
`scout add "people.Franklin.height"=165` will create a new dictionary Franklin and add a height key into it with the value 165
`scout add "people.Tom.hobbies[-1]"=Playing music"` will add the hobby "Playing music" to Tom hobbies at the end of the array
`scout add "people.Arnaud.hobbies[1]"=reading` will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party"
`scout add "people.Arnaud.hobbies[-1]"=surf` will add the hobby "surf" to Arnaud hobbies at the end of the array
`scout add "people.Franklin.hobbies[0]"=football` will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array
"""

struct ScoutCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
            commandName: "scout",
            abstract: abstract,
            discussion: discussion,
            subcommands: [
                ReadCommand.self,
                SetCommand.self,
                DeleteCommand.self,
                AddCommand.self,
                VersionCommand.self],
            defaultSubcommand: ReadCommand.self)

    static func output<T: PathExplorer>(_ output: String?, dataWith pathExplorer: T, verbose: Bool) throws {
        if let output = output?.replacingTilde {
            let fm = FileManager.default
            try fm.createFile(atPath: output, contents: pathExplorer.exportData(), attributes: nil)
        }

        if verbose {
            print(try pathExplorer.exportString())
        }
    }
}
