//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

/// Array slice or dictionary filter found in a `Path`
enum GroupSample: CustomStringConvertible {
    case arraySlice, dictionaryFilter

    var description: String {
        switch self {
        case .arraySlice: return "an Array"
        case .dictionaryFilter: return "a Dictionary"
        }
    }
}
