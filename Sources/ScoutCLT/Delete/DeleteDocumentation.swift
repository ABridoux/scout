//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

struct DeleteDocumentation: Documentation {
    private static let jsonInjector = JSONInjector(type: .terminal)

    static let recursive = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-r")

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

    private static let examples = [(#"`scout delete "people.Tom.height"`"#, #"will delete Tom height"#),
                                   (#"`scout delete "people.Tom.hobbies[0]"`"#, #"will delete Tom first hobby"#),
                                   (#"`scout delete "people.Tom.hobbies[-1]"`"#, #"will delete Tom last hobby"#),
                                   (#"`scout delete "people.Arnaud.#h.*#"`"#, #"will delete Arnaud's height and hobbies"#),
                                   (#"`scout delete "people.Arnaud.hobbies[-2:]"`"#, #"will delete Arnaud's last two hobbies"#),
                                   (#"`scout delete "people.#.*#.hobbies[:1]`""#, #"will delete Tom's and Arnaud's first two hobbies"#),
                                   (#"`scout delete -r "people.#.*#.hobbies[:1]"`"#, #"will delete Arnaud's first two hobbies and Tom hobbies"#)]

    static let text =
    """

    Delete command
    ============

    Notes
    -----
    - When accessing an array value by its index, use the index -1 to access to the last element
    - Use the flag \(recursive) to delete an array or a dictionary key when left empty
    - Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
        - No lower means 0 like [:10] and no upper means the last index like [10:].
        - Use a negative index for the lower bound to target the last nth elements like [-4:] to target the last 4 elements
    - Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device

    - You can delete multiple values in one command
    - If the path is invalid, the program will return an error
    - Deactivate the output colorization with \(noColor) or \(nc).
        Useful if you encounter slowdowns when dealing with large files although it is not recommended to ouput large files in the terminal.
    - Output an array or a dictionary of arrays with the \(csv) flag or \(csvSep) option
    - Fold the arrays and dictionaries at a certain depth level with the \(level) option

    Examples
    --------

    JSON file

    \(jsonInjector.inject(in: jsonExample))

    \(examplesText(from: examples))
    """
}
