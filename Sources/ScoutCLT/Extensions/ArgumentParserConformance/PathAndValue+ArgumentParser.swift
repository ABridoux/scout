//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ScoutCLTCore
import ArgumentParser

extension PathAndValue: ExpressibleByArgument {

    private static var abstract: String {
        """
        Let you specify a reading path with an associated value. Like this: "FirstKey.SecondKey[Index].ThirdKey=value"
        or `"FirstKey[Index]=Text value with spaces"`
        """
    }

    static var help: ArgumentHelp { ArgumentHelp(abstract, valueName: "path=value", shouldDisplay: true) }

    public init?(argument: String) {
        self.init(string: argument)
    }
}
