//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

// MARK: - IntWrapper

extension Bounds {

    /// Wrapper around an `Int` value to avoid to make all the `Bounds` mutable.
    /// - note: `Bounds` will only mutate those `IntWrapper` values internally.
    @propertyWrapper
    final class IntWrapper {

        // MARK: Properties

        var wrappedValue: Int?
    }
}

// MARK: - Hashable

extension Bounds.IntWrapper: Hashable {

    static func == (lhs: Bounds.IntWrapper, rhs: Bounds.IntWrapper) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
