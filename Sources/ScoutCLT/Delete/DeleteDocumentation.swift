import ArgumentParser
import Lux

struct DeleteDocumentation: Documentation {
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

    private static let examples = [(#"`scout delete "people.Tom.height"`"#, #"will delete Tom height"#),
                                   (#"`scout delete "people.Tom.hobbies[0]"`"#, #"will delete Tom first hobby"#),
                                   (#"`scout delete "people.Tom.hobbies[-1]"`"#, #"will delete Tom last hobby"#)]

    static let text =
    """

    Delete command
    ============

    Notes
    -----
    - If the path is invalid, the program will return an error
    - You can delete multiple values in one command
    - When accessing an array value by its index, use the index -1 to access to the last element
    - Specify the \(zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-v")) flag to see the modified data

    Examples
    --------

    JSON file
    
    \(jsonInjector.inject(in: jsonExample))

    \(examplesText(from: examples))
    """
}
