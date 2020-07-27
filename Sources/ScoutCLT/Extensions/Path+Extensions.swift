//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation

extension Path: ExpressibleByArgument {

    public init?(argument: String) {
        try? self.init(string: argument)
    }
}
