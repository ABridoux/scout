import ArgumentParser

enum Command: String, ExpressibleByArgument {
    case read, set, delete, add
}
