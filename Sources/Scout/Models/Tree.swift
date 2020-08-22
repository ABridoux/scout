//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

struct Tree<Value: Comparable> {

    var first: Node?

    init() {}

    mutating func insert(value: Value) -> Int {
        guard let node = first else {
            first = Node(value: value)
            return 0
        }


        return insert(value: value, in: node)
    }

    private mutating func insert(value: Value, in node: Node, index: Int = 0) -> Int {

        if value < node.value {
            node.leftChildrenCount += 1
            if let left = node.leftChild {
                return insert(value: value, in: left, index: index)
            } else {
                let newLeftChild = Node(value: value)
                node.leftChild = newLeftChild
                return index
            }
        } else if value > node.value {
            let index = node.leftChildrenCount + index + 1 
            if let right = node.rightChild {
                return insert(value: value, in: right, index: index)
            } else {
                let newRightChild = Node(value: value)
                node.rightChild = newRightChild
                return index
            }
        } else {
            return index
        }
    }

    class Node {
        let value: Value
        var leftChild: Node?
        var rightChild: Node?
        var leftChildrenCount = 0

        init(value: Value) {
            self.value = value
        }
    }
}
