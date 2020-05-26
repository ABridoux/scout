import Scout

extension PathExplorerError {

    var commandLineErrorDescription: String {
        var description = "Error".error + ": "

        switch self {
        case .invalidData(let type): description += "Cannot intialize a \(String(describing: type).bold) object with the given data"
        case .invalidValue(let value): description += "The key value \(String(describing: value).bold) is invalid"
        case .valueConversionError(let value, let type): description += "Unable to convert the value \(String(describing: value).bold) to \(String(describing: type).bold)"
        case .wrongValueForKey(let value, let element): description += "Cannot set \(String(describing: value).bold) to key/index \(String(describing: element).bold) which is a Dictionary or an Array"

        case .dictionarySubscript(let path): description += "Cannot subscript the key at '\(path.description.bold)' as it is not a Dictionary"
        case .subscriptMissingKey(let path, let key, let bestMatch):
            let bestMatchString: String

            if let match = bestMatch {
                bestMatchString = "Best match found: \(match.bold)"
            } else {
                bestMatchString = "No best match found"
            }

            description += "The key \(key.bold) cannot be found in the Dictionary '\(path.description.bold)'. \(bestMatchString)"

        case .arraySubscript(let path): description += "Cannot subscript the key at '\(path.description.bold)' as is not an Array"
        case .subscriptWrongIndex(let path, let index, let arrayCount): description += "The index \(String(index).bold) is not within the bounds of the Array (0...\(arrayCount - 1)) at '\(path.description)'"

        case .stringToDataConversionError: description += "Unable to convert the input string into data"
        case .dataToStringConversionError: description += "Unable to convert the data to a string"
        case .invalidPathElement(let element): description += "Invalid path element: \(String(describing: element).bold)"

        case .underlyingError(let message): description += message
        }

        return description
    }
}
