//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

enum DeleteDocumentation: Documentation {

    static let recursive = zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-r")

    private static let examples =
        [(#"`scout delete "Tom.height"`"#, #"will delete Tom height"#),
         (#"`scout delete "Tom.hobbies[0]"`"#, #"will delete Tom first hobby"#),
         (#"`scout delete "Tom.hobbies[-1]"`"#, #"will delete Tom last hobby"#),
         (#"`scout delete "Arnaud.#h.*#"`"#, #"will delete Arnaud's height and hobbies"#),
         (#"`scout delete "Arnaud.hobbies[-2:]"`"#, #"will delete Arnaud's last two hobbies"#),
         (##"`scout delete "#.*#.hobbies[:1]`""##, #"will delete Tom's and Arnaud's first two hobbies"#),
         (##"`scout delete -r "#.*#.hobbies[:1]"`"##, #"will delete Arnaud's first two hobbies and Tom hobbies"#),
         (#"`scout delete "Tom.height -e plist"`"#, #"will delete Tom height and convert the modified data to a Plist format"#)]

    static let text =
    """

    --------------
    Delete command
    --------------

    \(DeleteCommand.configuration.abstract)

    \(notesHeader)

    \(commonDoc)

    \(header: "Several paths")
    It's possible to set multiple values in one command by specifying several path/value pairs.

    \(header: "Delete if empty")
    Use the flag \(recursive) to delete an array or a dictionary key when left empty

    \(slicingAndFilteringDoc)

    \(miscDoc)

    \(examplesHeader)

    JSON file

    \(injectedJSONExample)

    \(examplesText(from: examples))
    """
}
