//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser

enum ReadDocumentation: Documentation {

    private static let examples =
        [(#"`scout read "Tom.hobbies[0]"`"#, #"will output Tom first hobby "cooking""#),
         (#"`scout read "Arnaud.height"`"#, #"will output Arnaud's height "180""#),
         (#"`scout read "Tom.hobbies[-1]"`"#, #"will output Tom last hobby: "guitar""#),
         (#"`scout read "Tom"`"#, #"will output Tom dictionary"#),
         (#"`scout read "[#]"`"#, #"will output the people count: 2"#),
         (#"`scout read "Arnaud.hobbies[#]"`"#, #"will output Arnaud's hobbies count: 3"#),
         (#"`scout read "Arnaud.#h.*#"`"#, #"will output Arnaud's height and hobbies"#),
         (#"`scout read "Arnaud.hobbies[1:]"`"#, #"will output Arnaud's last two hobbies"#),
         (#"`scout read "Arnaud.hobbies[-2:]"`"#, #"will output Arnaud's last two hobbies"#),
         (##"`scout read "#.*#.hobbies[:1]"`"##, #"will output Tom's and Arnaud's first two hobbies"#),
         (##"`scout read "#.*#.hobbies[#]"`"##, #"will output Tom's and Arnaud's hobbies count"#),
         (#"`scout read "Tom.hobbies[:]" --csv`"#, #"will ouput Tom hobbies as CSV"#),
         (#"`scout read -i People.json -e yaml`"#, #"will convert the JSON file to YAML"#)]

    static let text =
    """

    ------------
    Read command
    ------------

    \(ReadCommand.configuration.abstract)

    Notes
    =====

    \(commonDoc)

    \(header: "Count/Keys symbols")
    - Get an dictionary or an array count with the '[#]' symbol.
    - List the keys of a dictionary witht the '{#}' symbol.

    \(slicingAndFilteringDoc)

    \(miscDoc)

    \(examplesHeader)

    JSON file

    \(injectedJSONExample)

    \(examplesText(from: examples))
    """
}
