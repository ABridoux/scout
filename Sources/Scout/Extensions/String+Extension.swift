import Foundation

extension String {

    subscript(_ range: Range<Int>) -> Substring {
        let sliceStartIndex = index(startIndex, offsetBy: range.lowerBound)
        let sliceEndIndex = index(startIndex, offsetBy: range.upperBound - 1)
        return self[sliceStartIndex...sliceEndIndex]
    }
}
