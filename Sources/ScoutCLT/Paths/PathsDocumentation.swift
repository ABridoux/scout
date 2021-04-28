//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Lux

enum PathsDocumentation: Documentation {
    private static let zshInjector = ZshInjector(type: .terminal)

    static let single = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--single")
    static let group = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--group")
    static let key = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-k|--key")
    static let value = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-v|--value")

    private static let examples: [CommandAndPaths] =
        [.init(#"`scout paths "Tom.hobbies"`"#, "Tom.hobbies", "Tom.hobbies[0]", "Tom.hobbies[1]"),
         .init(#"`scout paths "Arnaud" --single`"#, "Arnaud.height", "Arnaud.age", "Arnaud.hobbies[0]", "Arnaud.hobbies[1]", "Arnaud.hobbies[2]"),
         .init(##"`scout paths "#Tom|Arnaud#.age"`"##, "Arnaud.age", "Tom.age"),
         .init(##"`scout paths "Arnaud.hobbies[:1]"`"##, "Arnaud.hobbies[0]", "Arnaud.hobbies[1]"),
         .init(##"`scout paths -k "he.*"`"##, "Arnaud.height", "Tom.height"),
         .init(##"`scout paths -v "value > 170`""##, "Arnaud.height", "Tom.height"),
         .init(##"`scout paths -v "value > 170" -v "value hasPrefix 'te'"`"##, "Arnaud.height", "Arnaud.hobbies[2]", "Tom.height"),
         .init(##"`scout paths "Arnaud" -k "hobbies" -v "value isIn 'party, tennis'"`"##, "Arnaud.hobbies[1]", "Arnaud.hobbies[2]")]

    static let text =
    """

    -------------
    Paths command
    -------------

    \(PathsCommand.configuration.abstract)

    \(notesHeader)

    \(header: "Initial path")
    It's possible to provide a path from which the paths should be listed.
    If no path is provided, the paths will start from the root array or dictionary.

    \(header: "Value target")
    Target single values (string, boolean, number) with \(single), group values (array, dictionary) with \(group), or both by default.

    \(header: "Filter keys")
    Specify a regular expression to filter the keys with the \(key) option.
    Only paths whose final key matches the regular expression will be included.

    \(header: "Filter value")
    Specify one or more predicates to filter the values with the \(value) option: "-v firstPredicate -v secondPredicate".
    A path whose value is validated by one of the predicates will be included.

    A predicate uses the variable 'value' to specify the value that will be replaced when evaluating the predicate.
    For instance, the predicate "value == 10" will filter all the values different from 10.
    The predicates "value hasPrefix 'to' && value hasSuffix 'ta'" will retrieve only the values starting with "to" and ending with "ta".

    If a value has not the right type, the predicate will be false.
    For instance, the value "light" will not be validated by the predicate "value > 10".

    Additional informations about predicates can be found by running `\(zsh: "scout doc -a predicates")`.

    \(slicingAndFilteringDoc)

    \(examplesHeader)

    JSON file

    \(injectedJSONExample)

    \(injectedExamples)
    """
}

extension PathsDocumentation {

    struct CommandAndPaths {
        var command: String
        var paths: [String]

        init(_ command: String, _ paths: String...) {
            self.command = command
            self.paths = paths
        }
    }
}

extension PathsDocumentation {

    static var injectedExamples: String {
        examples.reduce("") { (result, commandAndPaths) in
            let command = zshInjector.inject(in: commandAndPaths.command)
            let paths = commandAndPaths.paths.joined(separator: "\n")
            return result + "\(command) will output\n\(paths)\n---------\n"
        }
    }
}
