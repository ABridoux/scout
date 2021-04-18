//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser

extension ArgumentHelp {

    static var readingPath: ArgumentHelp {
        ArgumentHelp(
            "Path in the data where to read the key value",
            discussion: """
                        A path is a sequence of keys separated with dots to navigate through the data.
                        A dot '.' is used to subscript a dictionary. For example 'dictionary.key'.
                        An integer enclosed by square brakets '[1]' is used to subscript an array. For example 'array[5]'.
                        """)
    }
}
