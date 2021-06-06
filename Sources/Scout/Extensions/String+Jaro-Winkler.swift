//
// Scout
// Copyright (c) 2020-present Alexis Bridoux
// MIT license, see LICENSE file for details

extension String {

    /// Jaro-Winkler distance between two strings, to evaluate a potential match
    /// - Parameter string: The other string to evaluate the distance from
    /// - Returns: Double between 0 and 1. 0 means no match at all. 1 means a perfect equality between the two strings.
    ///
    /// Useful links:
    /// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
    func jaroWinklerDistance(from string: String) -> Double { JaroWinklerDistance(self, string).computeDistance() }

    func bestJaroWinklerMatchIn(propositions: Set<String>) -> String? {
        guard
            let bestMath = propositions.max(by: { jaroWinklerDistance(from: $0) < jaroWinklerDistance(from: $1) }),
            jaroWinklerDistance(from: bestMath) >= 0.5
        else { return nil }

        return bestMath
    }
}

/// Wrap the computations for the Jaro-Winkler
///
/// Useful links:
/// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
private struct JaroWinklerDistance {
    var string1: String
    var string2: String
    var count1: Int { string1.count }
    var count2: Int { string2.count }
    let maxSpacing: Int

    init(_ string1: String, _ string2: String) {
        self.string1 = string1
        self.string2 = string2

        maxSpacing = max(0, max(string1.count, string2.count) / 2 - 1)
    }

    func computeMatches() -> [Int] {
        var matches = [Int]()

        for index in 0..<min(count1, count2) where match(at: index) {
            matches.append(index)
        }

        return matches
    }

    /// Match when the range defined by index +/- maxSpacing contains the current character
    func match(at index: Int) -> Bool {
        let lowerBound = max(index - maxSpacing, 0)
        let upperBound = min(index + maxSpacing, count1 - 1, count2 - 1)
        let substring1 = string1[string1.index(string1.startIndex, offsetBy: index)].lowercased()
        let lowerIndex = string2.index(string2.startIndex, offsetBy: lowerBound)
        let upperIndex = string2.index(string2.startIndex, offsetBy: upperBound)

        for character in string2[lowerIndex..<upperIndex] where substring1 == character.lowercased() {
            return true
        }
        return false
    }

    func computeTranspositions(in matches: [Int]) -> Double {
        var t = 0.0

        let matchesCount = matches.count
        var index = 0
        var matchesIndex = 0

        var iterator1 = string1.makeIterator()
        var iterator2 = string2.makeIterator()

        while let char1 = iterator1.next(), let char2 = iterator2.next() {
            defer { index += 1 }
            guard matchesIndex < matchesCount else { break }
            guard matches[matchesIndex] == index else { continue }
            matchesIndex += 1

            if char1 != char2 {
                t += 1
            }
        }

        return t / 2.0
    }

    func computeJaroDistance(m: Int, t: Double) -> Double {
        let m = Double(m)
        let count1 = Double(self.count1)
        let count2 = Double(self.count2)

        return (m/count1 + m/count2 + (m - t)/m) / 3.0
    }

    func computeJaroWinklerDistance(dj: Double, p: Double = 0.1) -> Double {
        let l = Double(computeCommonPrefixLength())

        return dj + (l * p * (1 - dj))
    }

    /// Compute the `l` in the formulae
    func computeCommonPrefixLength() -> Int {
        var length = 0
        let maxCount = min(4, count1, count2)
        var count = 0
        var index1 = string1.startIndex
        var index2 = string2.startIndex

        while count < maxCount {
            if string1[index1] == string2[index2] {
                length += 1
            } else {
                break
            }
            count += 1
            index1 = string1.index(after: index1)
            index2 = string2.index(after: index2)
        }
        return length
    }

    /// Compute the Jaro-Winkler distance between the two strings
    func computeDistance() -> Double {
        let matches = computeMatches()

        guard matches.count > 0 else {
            return 0
        }

        let t = computeTranspositions(in: matches)
        let dj = computeJaroDistance(m: matches.count, t: t)

        return computeJaroWinklerDistance(dj: dj)
    }
}
