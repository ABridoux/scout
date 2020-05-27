import Lux

final class XMLInjectorColorDelegate: XMLEnhancedDelegate {

    // MARK: - Properties

    let colors: XmlColors

    // MARK: - Initialisation

    init(colors: XmlColors) {
        self.colors = colors
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Functions

    override func injection(for category: XMLEnhancedCategory, type: TextType) -> String {
        var colorCode: Int?

        switch category {
        case .openingTag: colorCode = colors.openingTag
        case .closingTag: colorCode = colors.closingTag
        case .punctuation: colorCode = colors.punctuation
        case .key: colorCode = colors.key
        case .comment: colorCode = colors.comment
        case .header: colorCode = colors.header
        }

        if let code = colorCode {
            return String.colorPrefix(code)
        } else {
            return super.injection(for: category, type: type)
        }
    }
}
