import Foundation

/// Array of `PathElement`s. Only `String` and `Int` to indicate a key name or an array index
public typealias Path = [PathElement]

public extension Path {

    // MARK: - Computed properties

    var description: String {
        var description = ""
        forEach {
            if let int = $0 as? Int {
                description.append("[\(int)]")
                description.append("->")
            } else {
                description.append(String(describing: $0))
            }
        }
        // remove the last arrow
        description.removeLast(2)
        return description
    }

    // MARK: - Initialization

    /**
     Instantiate a `Path` for a string representing path components separated with the separator.

     ### Example with default separator "."

     ```computers[2].name``` will make the path ["computers", 2, "name"]
     ```computer.general.serial_number``` will make the path ["computer", "general", "serial_number"]

     - parameter string: The string representing the path
     - parameter separator: The separator used to split the string. Default is "."

     - note: When enclosed with brackets, a path element will not be parsed. For example ```computer.(general.information).serial_number```
     will make the path ["computer", "general.information", "serial_number"]

     - note: The following separators will not work: "[", "]", "(", ")".
     When using a special caracter with [regular expression](https://developer.apple.com/documentation/foundation/nsregularexpression#1965589),
     it is required to quote it with "\\".

    */
    init(string: String, separator: String = "\\.") throws {
        var elements = [PathElement]()

        let splitRegexPattern = #"\(.+\)|[^\#(separator)]+"#
        let indexRegexPattern = #"(?<=\[)[0-9-]+(?=\])"#
        let splitRegex = try NSRegularExpression(pattern: splitRegexPattern, options: [])
        let indexRegex = try NSRegularExpression(pattern: indexRegexPattern, options: [])

        let matches = splitRegex.matches(in: string)
        for match in matches {

            // remove the brackets if any
            var match = match
            if match.hasPrefix("("), match.hasSuffix(")") {
                match.removeFirst()
                match.removeLast()
            }

            // try to get the index if any
            if let indexMatch = indexRegex.firstMatch(in: match, options: [], range: match.nsRange) {
                guard indexMatch.range.lowerBound > 1 else { throw PathExplorerError.invalidPathElement(match) }
                // get the array name
                let newMatch = String(match[0..<indexMatch.range.lowerBound - 1])
                // get the array index
                guard let index = Int(match[indexMatch.range]) else { throw PathExplorerError.invalidPathElement(match) }

                elements.append(newMatch)
                elements.append(index)

            } else {
                elements.append(match)
            }
        }

        self = elements
    }

    // MARK: - Functions

    static func == (lhs: Path, rhs: Path) -> Bool {
        guard lhs.count == rhs.count else { return false }

        var isEqual = true
        for (leftElement, rightElement) in zip(lhs, rhs) {
            if let leftString = leftElement as? String {
                guard let rightString = rightElement as? String else { return false }
                isEqual = isEqual && leftString == rightString
            } else if let leftInt = leftElement as? Int {
                guard let rightInt = rightElement as? Int else { return false }
                isEqual = isEqual && rightInt == leftInt
            } else {
                assertionFailure("Only String and Int can be PathElement")
                return false
            }
        }
        return isEqual
    }
}
