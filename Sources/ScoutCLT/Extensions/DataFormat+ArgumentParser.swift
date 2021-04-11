//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Scout
import ArgumentParser

extension DataFormat: ExpressibleByArgument {}

extension DataFormat: EnumerableFlag {

    public static func name(for value: DataFormat) -> NameSpecification {
        switch value {
        case .json: return [.long, .customShort("J")]
        case .plist: return [.long, .customShort("P")]
        case .xml: return [.long, .customShort("X")]
        case .yaml: return [.long, .customShort("Y")]
        }
    }
}
