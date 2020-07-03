import ArgumentParser
import Lux

struct ReadDocumentation: Documentation {
    private static let jsonInjector = JSONInjector(type: .terminal)
    private static let zshInjector = ZshInjector(type: .terminal)

    private static let jsonExample =
    """
    {
      "people": {
        "Tom": {
          "height": 175,
          "age": 68,
          "hobbies": [
            "cooking",
            "guitar"
          ]
        },
        "Arnaud": {
          "height": 180,
          "age": 23,
          "hobbies": [
            "video games",
            "party",
            "tennis"
          ]
        }
      }
    }
    """

    private static let examples = [(#"`scout "people.Tom.hobbies[0]"`"#, #"will output Tom first hobby "cooking")"#),
                                   (#"`scout "people.Arnaud.height"`"#, #"will output Arnaud's height "180""#),
                                   (#"`scout "people.Tom.hobbies[-1]"`"#, #"will output Tom last hobby: "guitar""#),
                                   (#"`scout "people.Tom`"#, #"will output Tom dictionary"#)]

    static let text =
    """

    Read command
    ============

    Notes
    -----
    - If the path is invalid, the program will return an error
    - Enclose the value with sharp signs to change the key name: #keyName#
    - When accessing an array value by its index, use the index -1 to access to the last element

    Examples
    --------

    JSON file
    
    \(jsonInjector.inject(in: jsonExample))

    \(examplesText(from: examples))
    """
}
