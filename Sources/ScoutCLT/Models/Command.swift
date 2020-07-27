//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser

enum Command: String, ExpressibleByArgument {
    case read, set, delete, add

    static var documentationDescription: String {
        "\(Self.read.rawValue.mainColor), \(Self.set.rawValue.mainColor), \(Self.delete.rawValue.mainColor) and \(Self.add.rawValue.mainColor)"
    }
}
