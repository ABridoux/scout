//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser

struct HomeDocumentation: Documentation {

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

    Current: \(main: Version.current)

    Scout offers features to manage data and support 4 data formats:
    - JSON
    - Plist
    - YAML
    - XML

    To explore data, the program deals with paths.
    \(ArgumentHelp.readingPath.discussion)

    You can find more examples here:
    \(main: "https://github.com/ABridoux/scout/wiki/%5B20%5D-Usage-examples:-command-line")

    \(examplesHeader)

    Given the following Json (as input stream or file)

    \(injectedJSONExample)

    - \(zshString: "Tom.height") targets Tom's height: 175
    - \(zshString: "Tom.hobbies[1]") targets Tom second hobby: "party"

    Overview
    ========

    \(header: "Reading")
    Read single values (e.g. strings), group values (e.g. arrays)
    and some other values like an array count or a dictionary keys list.
    More info: \(zsh: "`scout doc -c read`")

    \(header: "Setting")
    Modify one or more existing single values or key names in the data.
    More info: \(zsh: "`scout doc -c set`")

    \(header: "Deleting")
    Delete one more values in the data.
    More info: \(zsh: "`scout doc -c delete`")

    \(header: "Adding")
    Add one or more values in the data. Add new keys to a dictionary,
    insert or add new values to an array.
    More info: \(zsh: "`scout doc -c add`")

    \(header: "Listing paths")
    List the paths in the data to parse its values.
    More info: \(zsh: "`scout doc -c paths`")

    """
}

struct DocCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "doc",
        abstract: "Rich examples and advanced explanations")

    @Option(name: [.short, .long], help: "Commands specific documentation: \(Command.documentationDescription)")
    var command: Command?

    @Option(name: [.short, .customLong("advanced")], help: "Advanced documentation on topics related to Scout")
    var advancedTopic: AdvancedDocumentation.Topic?

    func run() throws {
        switch (command, advancedTopic) {
        case (nil, nil): print(HomeDocumentation.text)
        case (.some(let command), nil): printCommand(command)
        case (nil, .some(let topic)): print(topic.doc)
        case (.some, .some): throw RuntimeError.invalidArgumentsCombination(description: "(-c|--command) and (-a|--advanced) cannot be used simultaneously")
        }
    }

    func printCommand(_ command: Command) {
        switch command {
        case .read: print(ReadDocumentation.text)
        case .set: print(SetDocumentation.text)
        case .delete: print(DeleteDocumentation.text)
        case .add: print(AddDocumentation.text)
        case .paths: print(PathsDocumentation.text)
        }
    }
}
