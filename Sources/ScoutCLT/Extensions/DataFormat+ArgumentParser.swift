//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser

extension DataFormat: ExpressibleByArgument {

    public var defaultValueDescription: String { "The data format to read the input" }
    static var name: NameSpecification = [.customShort("f", allowingJoined: true), .customLong("format")]
}
