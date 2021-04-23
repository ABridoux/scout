//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser

extension DataFormat: ExpressibleByArgument {

    public var defaultValueDescription: String { "The data format to read the input" }
}
