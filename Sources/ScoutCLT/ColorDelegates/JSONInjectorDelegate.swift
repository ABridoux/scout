import Lux

final class JSONInjectorColorDelegate: JSONDelegate {

    // MARK: - Properties

    let colors: JsonColors

    // MARK: - Initialisation

    init(colors: JsonColors) {
        self.colors = colors
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Functions

    override func injection(for category: JSONCategory, type: TextType) -> String {
        var colorCode: Int?

        switch category {
        case .punctuation: colorCode = colors.punctuation
        case .keyName: colorCode = colors.keyName
        case .keyValue: colorCode = colors.punctuation
        }

        if let code = colorCode {
            return String.colorPrefix(code)
        } else {
            return super.injection(for: category, type: type)
        }
    }
}
