import Lux

final class PlistInjectorColorDelegate: PlistDelegate {

    // MARK: - Properties

    let colors: PlistColors

    // MARK: - Initialisation

    init(colors: PlistColors) {
        self.colors = colors
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    // MARK: - Functions

    override func injection(for category: PlistCategory, type: TextType) -> String {
        var colorCode: Int?

        switch category {
        case .tag: colorCode = colors.tag
        case .keyName: colorCode = colors.keyName
        case .keyValue: colorCode = colors.keyValue
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
