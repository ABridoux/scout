//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension PathExplorer {

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd<T>(_ element: PathElementRepresentable, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd(_ element: PathElementRepresentable, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd<T>(_ element: PathElement, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// Add the element to the thrown `ValueTypeError` if any
    func doAdd(_ element: PathElement, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.adding(element)
        }
    }

    /// do/catch on the provided block to catch a `ValueTypeError` and set the provided path on it
    func doSettingPath(_ path: Slice<Path>, _ block: () throws -> Void) rethrows {
        do {
            try block()
        } catch let error as ExplorerError {
            throw error.with(path: path)
        }
    }

    /// do/catch on the provided block to catch a `ValueTypeError` and set the provided path on it
    func doSettingPath<T>(_ path: Slice<Path>, _ block: () throws -> T) rethrows -> T {
        do {
            return try block()
        } catch let error as ExplorerError {
            throw error.with(path: path)
        }
    }
}
