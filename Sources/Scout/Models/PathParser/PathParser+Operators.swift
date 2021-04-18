//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

extension PathParser {

    var many: PathParser<[R]> {
        PathParser<[R]> { input in
            var result: [R] = []
            var remainder = input

            while let (element, newRemainder) = parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }

            return (result, remainder)
        }
    }

    var many1: PathParser<[R]> {
        curry { [$0] + $1 } <^> self <*> many
    }

    func map<T>(_ transform: @escaping (R) -> T) -> PathParser<T> {
        PathParser<T> { input in
            guard let (result, remainder) = parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    func followed<A>(by other: PathParser<A>) -> PathParser<(R, A)> {
        PathParser<(R, A)> { input in
            guard let (result, remainder) = parse(input) else { return nil }
            guard let (secondResult, secondRemainder) = other.parse(remainder) else { return nil }
            return ((result, secondResult), secondRemainder)
        }
    }

    func or(_ other: PathParser) -> PathParser<R> {
        PathParser<R> { input in
            parse(input) ?? other.parse(input)
        }
    }

    var optional: PathParser<R?> {
        PathParser<R?> { input in
            guard let (result, remainder) = parse(input) else {
                return (nil, input)
            }
            return (result, remainder)
        }
    }
}

// MARK: - Operators

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    { a in { b in f(a, b) }}
}

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    { a in { b in { c in f(a, b, c) }}}
}

func <^><A, B>(lhs: @escaping (A) -> B, rhs: PathParser<A>) -> PathParser<B> { rhs.map(lhs) }

infix operator <*>: SequencePrecedence
func <*><A, B>(lhs: PathParser<(A) -> B>, rhs: PathParser<A>) -> PathParser<B> {
    lhs.followed(by: rhs).map { f, op in f(op) }
}

infix operator *>: SequencePrecedence
func *><A, B>(lhs: PathParser<A>, rhs: PathParser<B>) -> PathParser<B> {
    curry { (_, b) in b } <^> lhs <*> rhs
}

infix operator <*: SequencePrecedence
func <*<A, B>(lhs: PathParser<A>, rhs: PathParser<B>) -> PathParser<A> {
    curry { (a, _) in a } <^> lhs <*> rhs
}

infix operator <|>: SequencePrecedence
func <|><A>(lhs: PathParser<A>, rhs: PathParser<A>) -> PathParser<A> {
    lhs.or(rhs)
}
