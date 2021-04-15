//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

struct ValidationError: LocalizedError {

    var message: String

    var errorDescription: String? { message }
}
