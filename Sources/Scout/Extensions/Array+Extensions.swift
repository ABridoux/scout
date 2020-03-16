import Foundation

extension Array {

    func getIfPresent(at index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }

        return self[index]
    }
}
