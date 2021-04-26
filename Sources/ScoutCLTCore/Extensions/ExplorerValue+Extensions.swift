//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation
import Scout

extension ExplorerValue {

    init(fromSingle string: String) {
        if let int = Int(string) {
            self = .int(int)
        } else if let double = Double(string) {
            self = .double(double)
        } else if let bool = Bool(string) {
            self = .bool(bool)
        } else {
            self = .string(string)
        }
    }
}
