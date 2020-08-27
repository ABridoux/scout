//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

struct AddDocumentation: Documentation {
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

    private static let examples = [(#"`scout add "people.Franklin.height=165"`"#, #"will create a new dictionary Franklin and add a height key into it with the value 165"#),
                                   (#"`scout add "people.Tom.hobbies[-1]"="Playing music"`"#, #"will add the hobby "Playing music" to Tom hobbies at the end of the array"#),
                                   (#"`scout add "people.Arnaud.hobbies[1]=reading"`"#, #"will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party""#),
                                   (#"`scout add "people.Franklin.hobbies[0]"=football`"#, """
                                                                                            will create a new dictionary Franklin,
                                                                                                add a hobbies array into it, and insert the value "football" in the array
                                                                                            """),
                                   (#"`scout add "people.Franklin.height=/165/"`"#, #"will create a new dictionary Franklin and add a height key into it with the String value "165""#),
                                   (#"`scout add "people.Franklin.height=~165~"`"#, #"will create a new dictionary Franklin and add a height key into it with the Real value 165 (Plist only)"#)]

    static let text =
    """

    Add command
    ============

    Notes
    -----
    - All the keys which do not exist in the path will be created
    - Enclose the value with slash signs to force the value as a string: /valueAsString/ (Plist, Json)
    - Enclose the value with interrogative signs to force the value as a boolean: ?valueToBoolean? (Plist, Json)
    - Enclose the value with tilde signs to force the value as a real: ~valueToReal~ (Plist)
    - Enclose the value with chevron signs to force the value as a integer: <valueToInteger> (Plist)
    - When adding an element in an array, use the index -1 to add the element at the end of the array

    - You can add multiple values in one command
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
