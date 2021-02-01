//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

struct HomeDocumentation: Documentation {

    private static let jsonInjector = JSONInjector(type: .terminal)
    private static let zshInjector = ZshInjector(type: .terminal)

    private static let jsonExample =
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

    private static let readExamples = [(#"`scout "people.Tom.hobbies[0]"`"#, #"will output "cooking""#),
                                (#"`scout "people.Arnaud.height"`"#, #"will output "180""#),
                                (#"`scout "people.Tom.hobbies[-1]"`"#, #"will output last Tom hobbies: "guitar""#),
                                (#"`scout "people.Tom`"#, #"will output Tom dictionary"#)]

    private static let setExamples = [(#"`scout set "people.Tom.hobbies[0]=basket"`"#, #"will change Tom first hobby from "cooking" to "basket""#),
                               (#"`scout set "people.Arnaud.height=160"`"#, #"will change Arnaud's height from 180 to 160"#),
                               (#"`scout set "people.Tom.age=#years#"`"#, #"will change Tom age key name from #age# to #years#"#),
                               (#"`scout set "people.Tom.hobbies[-1]"="playing music""#, #"will change Tom last hobby from "guitar" to "playing music""#)]

    private static let deleteExamples = [(#"`scout delete "people.Tom.height"`"#, #"will delete Tom height"#),
                                  (#"`scout delete "people.Tom.hobbies[0]"`"#, #"will delete Tom first hobby"#),
                                  (#"`scout delete "people.Tom.hobbies[-1]"`"#, #"will delete Tom last hobby"#)]

    private static let addExamples = [(#"`scout add "people.Franklin.height=165"`"#, #"will create a new dictionary Franklin and add a height key into it with the value 165"#),
                               (#"`scout add "people.Tom.hobbies[-1]"="Playing music"`"#, #"will add the hobby "Playing music" to Tom hobbies at the end of the array"#),
                               (#"`scout add "people.Arnaud.hobbies[1]=reading"`"#, #"will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party""#),
                               (#"`scout add "people.Arnaud.hobbies[-1]=surf"`"#, #"will add the hobby "surf" to Arnaud hobbies at the end of the array"#),
                               (#"`scout add "people.Franklin.hobbies[0]=football"`"#, #"will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array"#)]

    static let text =
    """
    \u{001B}[38;5;88m
        ______     ______    ___   _____  _____  _________
      .' ____ \\  .' ___  | .'   `.|_   _||_   _||  _   _  |
      | (___ \\_|/ .'   \\_|/  .-.  \\ | |    | |  |_/ | | \\_|
       _.____`. | |       | |   | | | '    ' |      | |
      | \\____) |\\ `.___.'\\\\  `-'  /  \\ \\__/ /      _| |_
       \\______.' `.____ .' `.___.'    `.__.'      |_____|

    \u{001B}[0;0m

    Here is an overview of scout subcommands: \(Command.documentationDescription).
    To get more insights for a specific command, please type `scout doc -c \("[command]".mainColor)`.

    To indicate what value to target, a reading path should be indicated.
    \(ArgumentHelp.readingPath.discussion)

    You can find more examples here: \("https://github.com/ABridoux/scout/wiki/%5B20%5D-Usage-examples:-command-line".mainColor)

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
    \(examplesText(from: readExamples))

    Setting
    -------
    \(examplesText(from: setExamples))

    Deleting
    --------
    \(examplesText(from: deleteExamples))

    Adding
    ------
    \(examplesText(from: addExamples))
    """
}

struct DocCommand: ParsableCommand {
static let configuration = CommandConfiguration(
    commandName: "doc",
    abstract: "Rich examples and advanced explanations")

    @Option(name: [.short, .long], help: "Command specific documentation: \(Command.documentationDescription)")
    var command: Command?

    func run() throws {
        if let command = command {
            switch command {
            case .read: print(ReadDocumentation.text)
            case .set: print(SetDocumentation.text)
            case .delete: print(DeleteDocumentation.text)
            case .deleteKey: print(DeleteDocumentation.text)
            case .add: print(AddDocumentation.text)
            }
        } else {
            print(HomeDocumentation.text)
        }
    }
}
