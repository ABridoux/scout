//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

enum AddDocumentation: Documentation {

    private static let examples =
        [(#"`scout add "Franklin.height=165"`"#, #"will create a new dictionary Franklin and add a height key into it with the value 165"#),
         (#"`scout add "Tom.hobbies[#]"="Playing music"`"#, #"will add the hobby "Playing music" to Tom hobbies at the end of the array"#),
         (#"`scout add "Arnaud.hobbies[-1]"="Playing music"`"#, #"will insert the hobby "Playing music" to Arnaud hobbies before the last hobby 'tennis'."#),
         (#"`scout add "Arnaud.hobbies[1]=reading"`"#, #"will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party""#),
         (#"`scout add "Franklin.hobbies[0]"=football`"#, #"will create a new dictionary Franklin, add a hobbies array into it, and insert the value "football" in the array"#),
         (#"`scout add "Franklin.height=/165/"`"#, #"will create a new dictionary Franklin and add a height key into it with the String value "165""#),
         (#"`scout add "Franklin.height=~165~"`"#, #"will create a new dictionary Franklin and add a height key into it with the Real value 165 (Plist only)"#),
         (#"`scout add "Franklin.height=165" -e xml`"#, #"will create the new value and convert the modified to a XML format"#)]

    static let text =
    """

    -----------
    Add command
    -----------

    \(AddCommand.configuration.abstract)

    \(notesHeader)

    \(commonDoc)

    \(header: "Several paths")
    It's possible to add multiple values in one command by specifying several path/value pairs.

    \(header: "Keys creation")
    All the keys which do not exist in the path will be created.

    \(header: "Append a value")
    To add a value at the end of an array, specify the '[#]' symbol rather than an index

    \(forceTypeDoc)

    \(examplesHeader)

    JSON file

    \(injectedJSONExample)

    \(examplesText(from: examples))
    """
}
