//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

struct ReadDocumentation: Documentation {
    private static let jsonInjector = JSONInjector(type: .terminal)

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

    private static let examples = [(#"`scout read "people.Tom.hobbies[0]"`"#, #"will output Tom first hobby "cooking""#),
                                   (#"`scout read "people.Arnaud.height"`"#, #"will output Arnaud's height "180""#),
                                   (#"`scout read "people.Tom.hobbies[-1]"`"#, #"will output Tom last hobby: "guitar""#),
                                   (#"`scout read "people.Tom"`"#, #"will output Tom dictionary"#),
                                   (#"`scout read "people[#]"`"#, #"will output the number of people: 2"#),
                                   (#"`scout read "people.Arnaud.hobbies[#]"`"#, #"will output Arnaud's hobbies count: 3"#),
                                   (#"`scout read "people.Arnaud.#h.*#"`"#, #"will output Arnaud's height and hobbies"#),
                                   (#"`scout read "people.Arnaud.hobbies[1:]"`"#, #"will output Arnaud's last two hobbies"#),
                                   (#"`scout read "people.Arnaud.hobbies[-1:]"`"#, #"will output Arnaud's last two hobbies"#),
                                   (#"`scout read "people.#.*#.hobbies[:1]"`"#, #"will output Tom's and Arnaud's first two hobbies"#),
                                   (#"`scout read "people.#.*#.hobbies[#]"`"#, #"will output Tom's and Arnaud's hobbies count"#)]

    static let text =
    """

    Read command
    ============

    Notes
    -----
    - If the path is invalid, the program will return an error
    - When accessing an array value by its index, use the index -1 to access to the last element
    - Get an dictionary or an array count with the '[#]' symbol
    - Target a slice in an array with square brackets and a double point ':' between the bounds: [lower:upper]
        - No lower means 0 like [:10] and no upper means the last index like [10:].
        - Use a negative index for the lower bound to target the last nth elements like [-3:] to target the last 4 elements
    - Target specific keys with a regular expression by enclosing it with sharp signs: #.*device.*# to target all the keys containing the word device

    - Deactivate the output colorization with \(noColor) or \(nc).
        Useful to export the data or if you encounter slowdowns when dealing with large files ((although it is not recommended to ouput large files in the terminal).
    - Output an array or a dictionary of arrays with the \(csv) flag or \(csvSep) option
    - Fold the arrays and dictionaries at a certain depth level with the \(level) option

    Examples
    --------

    JSON file

    \(jsonInjector.inject(in: jsonExample))

    \(examplesText(from: examples))
    """
}
