extension String {

    subscript(_ index: Int) -> Character {
        let index = self.index(startIndex, offsetBy: index)
        return self[index]
    }

    /// Jaro-Winkler distance between two strings, to evaluate a potential match
    /// - Parameter string: The other string to evaluate the distance from
    /// - Returns: Double between 0 and 1. 0 means no match at all. 1 means a perfect equality between the two strings.
    ///
    /// Useful links:
    /// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
    public func jaroWinklerDistanceFrom(_ string: String) -> Double { JaroWinklerDistance(self, string).computeDistance() }

    public func bestJaroWinklerMatchIn(propositions: Set<String>) -> String? {
        let sortedPropositions = propositions.sorted { self.jaroWinklerDistanceFrom($0) > self.jaroWinklerDistanceFrom($1) }

        guard let firstMatch = sortedPropositions.first else { return nil }
        return firstMatch.jaroWinklerDistanceFrom(self) >= 0.5 ? firstMatch : nil
    }
}

/// Wrap the computations for the Jaro-Winkler
///
/// Useful links:
/// - [Wikipedia](https://en.wikipedia.org/wiki/Jaro–Winkler_distance)
private struct JaroWinklerDistance {
    var string1: String
    var string2: String

    // avoid to recompute the strings counts each time
    var count1: Int
    var count2: Int

    var maxSpacing: Int

    init(_ string1: String, _ string2: String) {
        self.string1 = string1
        self.string2 = string2
        count1 = string1.count
        count2 = string2.count

        maxSpacing = max(string1.count, string2.count) / 2 - 1
    }

    func computeMatches() -> [Int] {
        var matches = [Int]()

        for index in 0..<min(count1, count2) where match(at: index) {
            matches.append(index)
        }

        return matches
    }

    func match(at index: Int) -> Bool {
        // match when the range defined by index +/- maxSpacing contains the current character
        let lowerBound = max(index - maxSpacing, 0)
        let upperBound = min(index + maxSpacing, count1 - 1, count2 - 1)

        for i in lowerBound...upperBound {
            if string1[index].lowercased() == string2[i].lowercased() {
                return true
            }
        }
        return false
    }

    func computeTranspositions(in matches: [Int]) -> Double {
        var t = 0.0

        for index in matches where string1[index] != string2[index] {
            t += 1
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

        for index in 0..<min(4, count1, count2) {
            if string1[index] == string2[index] {
                length += 1
            } else {
                return length
            }
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
