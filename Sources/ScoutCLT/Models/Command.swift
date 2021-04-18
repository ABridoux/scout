//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import ArgumentParser

enum Command: String, ExpressibleByArgument, CaseIterable {
    case read, set, delete, add, paths

    static var documentationDescription: String {
        "\(Self.read.rawValue.mainColor), \(Self.set.rawValue.mainColor), \(Self.delete.rawValue.mainColor) and \(Self.add.rawValue.mainColor)"
    }
}
