import Foundation

/// Array of `PathElement`s
public typealias Path = [PathElement]

public extension Path {

    /**
    Instantiate a `Path` for a string representing path components separated with arrows

     ### Example
     - ```computers->[2]->name``` will make the path ["computers", 2, "name"]
     - ```computer->general->serial_number``` will make the path ["computer", "general", "serial_number"]

     - parameter string: The string representing the path
    */
    init(string: String) throws {
        var components = [PathElement]()

        for component in string.components(separatedBy: "->").map({ $0.trimmingCharacters(in: .whitespaces) }) {

            if component.hasPrefix("["), component.hasSuffix("]") {
                // array index so remove the square brackets and try to convert to int
                let indexComponentString = component[1..<component.count - 1]
                guard let indexComponent = Int(indexComponentString) else {
                    throw PathExplorerError.stringToIntConversionError(string)
                }

                components.append(indexComponent)
            } else {
                components.append(String(component))
            }
        }
        self = components
    }
}
