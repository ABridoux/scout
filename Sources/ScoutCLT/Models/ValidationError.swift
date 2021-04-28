//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

struct ValidationError: LocalizedError {

    var message: String

    var errorDescription: String? { message }
}
