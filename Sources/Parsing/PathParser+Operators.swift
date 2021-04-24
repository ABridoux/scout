//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

import Foundation

public extension Parser {

    var many: Parser<[R]> {
        Parser<[R]> { input in
            var result: [R] = []
            var remainder = input

            while let (element, newRemainder) = parse(remainder) {
                result.append(element)
                remainder = newRemainder
            }

            return (result, remainder)
        }
    }

    var many1: Parser<[R]> {
        curry { [$0] + $1 } <^> self <*> many
    }

    func map<T>(_ transform: @escaping (R) -> T) -> Parser<T> {
        Parser<T> { input in
            guard let (result, remainder) = parse(input) else { return nil }
            return (transform(result), remainder)
        }
    }

    func followed<A>(by other: Parser<A>) -> Parser<(R, A)> {
        Parser<(R, A)> { input in
            guard let (result, remainder) = parse(input) else { return nil }
            guard let (secondResult, secondRemainder) = other.parse(remainder) else { return nil }
            return ((result, secondResult), secondRemainder)
        }
    }

    func or(_ other: Parser) -> Parser<R> {
        Parser<R> { input in
            parse(input) ?? other.parse(input)
        }
    }

    var optional: Parser<R?> {
        Parser<R?> { input in
            guard let (result, remainder) = parse(input) else {
                return (nil, input)
            }
            return (result, remainder)
        }
    }
}

// MARK: - Operators

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    { a in { b in f(a, b) }}
}

public func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    { a in { b in { c in f(a, b, c) }}}
}

precedencegroup SequencePrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator <^>: SequencePrecedence

public func <^><A, B>(lhs: @escaping (A) -> B, rhs: Parser<A>) -> Parser<B> { rhs.map(lhs) }

infix operator <*>: SequencePrecedence
public func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    lhs.followed(by: rhs).map { f, op in f(op) }
}

infix operator *>: SequencePrecedence
public func *><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    curry { (_, b) in b } <^> lhs <*> rhs
}

infix operator <*: SequencePrecedence
public func <*<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
    curry { (a, _) in a } <^> lhs <*> rhs
}

infix operator <|>: SequencePrecedence
public func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    lhs.or(rhs)
}
