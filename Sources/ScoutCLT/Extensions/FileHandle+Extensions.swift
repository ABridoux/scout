//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension FileHandle {

    /// `true` is the file handle is piped
    ///
    /// For example on the standard output, this allows to know whether the output is piped or printed in the terminal
    /// - note: I think it's O(1) but I cant find any documentation on `isatty()`
    var isPiped: Bool { isatty(fileDescriptor) == 0 }
}
