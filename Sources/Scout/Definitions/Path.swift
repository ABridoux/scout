import Foundation

/// Array of `PathElement`s. Only `String` and `Int` to indicate a key name or an array index
public typealias Path = [PathElement]

public extension Path {

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
    /**
    Instantiate a `Path` for a string representing path components separated with arrows

     ### Example with default separator "->"
     - ```computers->[2]->name``` will make the path ["computers", 2, "name"]
     - ```computer->general->serial_number``` will make the path ["computer", "general", "serial_number"]

     - parameter string: The string representing the path
     - parameter separator: The separator used to split the string. Default is "->"
    */
    init(string: String, separator: String = "->") throws {
        var elements = [PathElement]()

        try string.components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespaces) }.forEach { element in

            if element.hasPrefix("["), element.hasSuffix("]") {
                // array index so remove the square brackets and try to convert to int
                let indexComponentString = element[1..<element.count - 1]
                guard let indexComponent = Int(indexComponentString) else {
                    throw PathExplorerError.stringToIntConversionError(string)
                }

                elements.append(indexComponent)
            } else {
                elements.append(String(element))
            }
        }
        self = elements
    }
}
