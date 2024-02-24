//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - ValueType

extension PathTree {

    enum ValueType: Equatable {
        case uninitializedLeaf
        case leaf(value: Value)
        case node(children: [PathTree])
    }
}
