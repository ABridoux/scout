//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser

extension ArgumentHelp {

    static var readingPath: ArgumentHelp {
        ArgumentHelp(
            "Path in the data where to read the key value",
            discussion: """
                        A path is a sequence of keys separated with dots to navigate through the data.
                        A dot '.' is used to subscript a dictionary. For example 'parent_key.child_key'.
                        An integer enclosed by square brakets '[1]' is used to subscript an array. For example 'first_key.array[0].second_key'
                        """)
    }
}
