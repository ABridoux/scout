//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Lux

/// Piece of documentation used to be printed
protocol Documentation {
    static var text: String { get }
}

extension Documentation {
    static var  zshInjector: ZshInjector<String, TerminalModifier, InjectorType<String, TerminalModifier>> { ZshInjector(type: .terminal) }

    static var noColor: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--no-color") }
    static var nc: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--nc") }
    static var csv: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--csv") }
    static var export: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-e|--export") }
    static var csvSep: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "--csv-sep") }
    static var level: String { zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-l") }

    /// Get one example per line
    /// - Parameters:
    ///   - examples: Array of (code, output) to display
    ///   - injector: Injector to use. Default is Zsh.
    /// - Returns: All examples with injected Zsh code
    static func examplesText(from examples: [(code: String, output: String)], with injector: TextInjector = ZshInjector(type: .terminal)) -> String {
        examples.reduce("") { (result, example) in
            "\(result) \(injector.inject(in: example.code)) \(example.output)\n"
        }
    }
}

extension Documentation {

    static var notesHeader: String {
        """
        Notes
        ====
        """
    }

    static var examplesHeader: String {
        """
        Examples
        ========
        """
    }

    static var commonDoc: String {
        """
        \(header: "Invalid path")
        If the path is invalid, the program will return an error.

        \(header: "Negative index subscripting")
        It's possible to access an element in an array by specifying its index starting from the end of the array.
        For instance, -2 targets the second element starting from the end.

        This figure gives an example with the 'ducks' array.

        ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
        [  0   ,   1   ,    2    ,    3    ,    4   ] (Positive)
        [ -5   ,  -4   ,   -3    ,   -2    ,   -1   ] (Negative)

        -> ducks[1] targets "Fifi"
        -> ducks[-2] targets "Donald"
        """
    }

    static var slicingAndFilteringDoc: String {
        """
        \(header: "Array slicing")
        Slice an array with square brackets and a double point ':' between the bounds: '[lower:upper]'.
        The upper bound is included.
        No lower means 0 like [:10] and no upper means the last index like [10:].

        Use a negative index to target the last nth elements like [-4:] to target the last 4 elements
        or [-4: -2] to target from the last fourth to the last second element.

        This figure gives an example with the 'ducks' array.

        ["Riri", "Fifi", "Loulou", "Donald", "Daisy"]
        [  0   ,   1   ,    2    ,    3    ,    4   ] (Positive)
        [ -5   ,  -4   ,   -3    ,   -2    ,   -1   ] (Negative)

        -> ducks[:1] targets ["Rifi", "Fifi"]
        -> ducks[-2:] targets ["Donald", "Daisy"]
        -> ducks [-3:-2] targets ["Loulou", "Donald"]

        \(header: "Keys filtering")
        Target specific keys in a dictionary with a regular expression by enclosing it with sharp signs.
        For instance #.*device.*# to target all the keys in a dictionary containing the word device.
        """
    }

    static var miscDoc: String {
        """
        \(header: "Color")
        Deactivate the output colorization with \(noColor) or \(nc).
        Automatically invoked when the output is piped or written in a file.
        Useful to avoid slowdowns when dealing with large files.

        \(header: "Export")
        Export the data to another available format with the \(export) command.
        Output an array or a dictionary of arrays as CSV with the \(csv) flag or \(csvSep) option.

        \(header: "Folding")
        Fold the arrays and dictionaries at a certain depth level with the \(level) option.
        """
    }

    static var forceTypeDoc: String {
        """
        \(header: "Forcing a type")
        String: enclose the value with slash signs to force the value as a string: /valueAsString/.
        Boolean: enclose the value with interrogative signs to force the value as a boolean: ?valueToBoolean?.
        Real: enclose the value with tilde signs to force the value as a real: ~valueToReal~.
        Integer: enclose the value with chevron signs to force the value as an integer: <valueToInteger>.
        """
    }
}


extension Documentation {

    static var jsonExample: String {
        """
        {
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
        """
    }

    static var injectedJSONExample: String {
        JSONInjector(type: .terminal).inject(in: jsonExample)
    }
}
