import Scout
import ArgumentParser

extension Path: ExpressibleByArgument {

    public init?(argument: String) {
        do {
            self = try Path(string: argument)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
