//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

/// Array slice or dictionary filter found in a `Path`
enum GroupSample: CustomStringConvertible {
    case arraySlice(Bounds)
    case dictionaryFilter(String)

    static var arraySliceEmpty: Self { .arraySlice(Bounds(lower: 0, upper: 0)) }
    static var dictionaryFilterEmpty: Self { .dictionaryFilter("") }

    var description: String {
        switch self {
        case .arraySlice: return "an Array"
        case .dictionaryFilter: return "a Dictionary"
        }
    }

    var pathElement: PathElement {
        switch self {
        case .arraySlice(let bounds): return .slice(bounds)
        case .dictionaryFilter(let pattern): return .filter(pattern)
        }
    }
}
