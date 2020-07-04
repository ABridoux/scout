import ArgumentParser
import Lux

private let jsonInjector = JSONInjector(type: .terminal)
private let zshInjector = ZshInjector(type: .terminal)

private let jsonExample =
"""
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
"""

private let readExamples = [#"`scout "people.Tom.hobbies[0]"`"#,
                            #"`scout "people.Arnaud.height"`"#,
                            #"`scout "people.Tom.hobbies[-1]"`"#,
                            #"`scout "people.Tom`"#]

private let setExamples = [#"`scout set "people.Tom.hobbies[0]=basket"`"#,
                           #"`scout set "people.Arnaud.height=160"`"#,
                           #"`scout set "people.Tom.age=#years#"`"#,
                           #"`scout set "people.Tom.hobbies[-1]"="playing music""#]

private let deleteExamples = [#"`scout delete "people.Tom.height"`"#,
                              #"`scout delete "people.Tom.hobbies[0]"`"#,
                              #"`scout delete "people.Tom.hobbies[-1]"`"#]

private let addExamples = [#"`scout add "people.Franklin.height=165"`"#,
                           #"`scout add "people.Tom.hobbies[-1]"="Playing music"`"#,
                           #"`scout add "people.Arnaud.hobbies[1]=reading"`"#,
                           #"`scout add "people.Arnaud.hobbies[-1]=surf"`"#,
                           #"`scout add "people.Franklin.hobbies[0]=football"`"#]

private let documentation =
"""
\u{001B}[38;5;88m
    ______     ______    ___   _____  _____  _________
  .' ____ \\  .' ___  | .'   `.|_   _||_   _||  _   _  |
  | (___ \\_|/ .'   \\_|/  .-.  \\ | |    | |  |_/ | | \\_|
   _.____`. | |       | |   | | | '    ' |      | |
  | \\____) |\\ `.___.'\\\\  `-'  /  \\ \\__/ /      _| |_
   \\______.' `.____ .' `.___.'    `.__.'      |_____|

\u{001B}[0;0m

Here is an overview of scout subcommands: read, set, delete and add.
To get more insights for a specifi command, please type `scout doc [command]`.

To indicate what value to target, a path should be indicated. A path is a serie of key names or indexes separated by '.' to target one value.
It looks like this "firt_key.second_key[second_index].third_key".

You can find more examples here: \u{001B}[38;5;88mhttps://github.com/ABridoux/scout/blob/master/Playground/Commands.md\u{001B}[0;0m

Notes
=====
- An index is indicated between squared brackets, like this [5]
- When reading a value, the output is always a string

Given the following Json (as input stream or file)

\(jsonInjector.inject(in: jsonExample))

Examples
========

Reading
-------
\(zshInjector.inject(in: readExamples[0])) will output "cooking"
\(zshInjector.inject(in: readExamples[1])) will output "180"
\(zshInjector.inject(in: readExamples[2])) will output last Tom hobbies: "guitar"
\(zshInjector.inject(in: readExamples[3])) will output Tom dictionary

Setting
-------
\(zshInjector.inject(in: setExamples[0])) will change Tom first hobby from "cooking" to "basket"
\(zshInjector.inject(in: setExamples[1])) will change Arnaud's height from 180 to 160
\(zshInjector.inject(in: setExamples[2])) will change Tom age key name from #age# to #years#
\(zshInjector.inject(in: setExamples[3])) will change Tom last hobby from "guitar" to "playing music"

Deleting
--------
\(zshInjector.inject(in: deleteExamples[0])) will delete Tom height
\(zshInjector.inject(in: deleteExamples[1])) will delete Tom first hobby
\(zshInjector.inject(in: deleteExamples[2])) will delete Tom last hobby

Adding
------
\(zshInjector.inject(in: addExamples[0])) will create a new dictionary Franklin and add a height key into it with the value 165
\(zshInjector.inject(in: addExamples[1])) will add the hobby "Playing music" to Tom hobbies at the end of the array
\(zshInjector.inject(in: addExamples[2])) will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party"
\(zshInjector.inject(in: addExamples[3])) will add the hobby "surf" to Arnaud hobbies at the end of the array
\(zshInjector.inject(in: addExamples[4])) will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array

"""

struct DocCommand: ParsableCommand {
static let configuration = CommandConfiguration(
    commandName: "doc",
    abstract: "Rich examples and advanced explanations")

    @Argument(help: "Command specific documentation")
    var command: Command?

    func run() throws {
        if let command = command {
            switch command {
            case .read: print(ReadDocumentation.text)
            case .set: print(SetDocumentation.text)
            case .delete: print(DeleteDocumentation.text)
            case .add: print(AddDocumentation.text)
            }
        } else {
            print(documentation)
        }
    }
}
