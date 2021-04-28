//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser
import Foundation

extension Path: ExpressibleByArgument {

    public init?(argument: String) {
        try? self.init(string: argument)
    }
}
