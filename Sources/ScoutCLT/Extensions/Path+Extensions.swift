import Scout
import ArgumentParser
import Foundation

extension Path: ExpressibleByArgument {

    public init?(argument: String) {
        try? self.init(string: argument)
    }
}
