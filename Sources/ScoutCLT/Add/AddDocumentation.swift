//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

enum AddDocumentation: Documentation {

    private static let examples =
        [(#"`scout add "Tom.hobbies[#]=Playing music"`"#, #"will add the hobby "Playing music" to Tom hobbies at the end of the array"#),
         (#"`scout add "Arnaud.hobbies[-1]=Playing music"`"#, #"will insert the hobby "Playing music" to Arnaud hobbies before the last hobby 'tennis'."#),
         (#"`scout add "Arnaud.hobbies[1]=reading"`"#, #"will insert the hobby "reading" to Arnaud hobbies between the hobby "video games" and "party""#),
         (#"`scout add "Franklin={}"`"#, #"will create a new empty dictionary at the key #Franklin#"#),
         (#"`scout add "Tom.colors=[]"`"#, #"will add a new empty #colors# array to Tom"#),
         (#"`scout add "Tom.score=/165/"`"#, #"will add a new #score# key to Tom with the String value "165""#)]

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
    Only when a key is the last one in the path will it be created. When an index is specified as the last element of the path,
    the value to add will be inserted at the index location.

    \(header: "Append a value")
    To add a value at the end of an array, specify the '[#]' symbol rather than an index

    \(valueSpecificationDoc)

    \(examplesHeader)

    JSON file

    \(injectedJSONExample)

    \(examplesText(from: examples))
    """
}
