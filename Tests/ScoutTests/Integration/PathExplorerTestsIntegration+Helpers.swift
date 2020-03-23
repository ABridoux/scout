import XCTest
import Scout

extension PathExplorerTestsIntegration {

    // MARK: - Get

    func testGet<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        do {
            switch value {
            case let stringValue as String:
                let value = try explorer.get(path).string
                XCTAssertEqual(value, stringValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(stringValue)", file: file, line: line)
            case let intValue as Int:
                let value = try explorer.get(path).int
                XCTAssertEqual(value, intValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(intValue)", file: file, line: line)
            case let doubleValue as Double:
                let value = try explorer.get(path).real
                XCTAssertEqual(value, doubleValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(doubleValue)", file: file, line: line)
            case let boolValue as Bool:
                let value = try explorer.get(path).bool
                XCTAssertEqual(value, boolValue, "\(explorer.format): \(value?.description ?? "nil") is not equal to \(boolValue)", file: file, line: line)
            default:
                assertionFailure("Value not a KeyAllowedType")
            }
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
        }
    }

    func testPathExplorersGet<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testGet(path: path, explorer: json, value: value, file: file, line: line)
        testGet(path: path, explorer: plist, value: value, file: file, line: line)
        testGet(path: path, explorer: xml, value: value, file: file, line: line)
    }

    // MARK: - Set

    func testSet<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        do {
            try explorer.set(path, to: value)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        testGet(path: path, explorer: explorer, value: value, file: file, line: line)
    }

    func testPathExplorersSet<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testSet(path: path, explorer: json, value: value, file: file, line: line)
        testSet(path: path, explorer: plist, value: value, file: file, line: line)
        testSet(path: path, explorer: xml, value: value, file: file, line: line)
    }

    // MARK: - Delete

    func testDelete<Explorer: PathExplorer>(path: Path, explorer: Explorer, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        let value: String
        do {
            value = try explorer.get(path).stringValue
            try explorer.delete(path)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        do {
            let newValue = try explorer.get(path).stringValue
            // if the value was deleted at -1 in an array, the array might still has a last value. So make sure it's not the same
            XCTAssertNotEqual(value, newValue, "\(explorer.format): The value at \(path) has not been deleted", file: file, line: line)
        } catch {
            switch error {
            case PathExplorerError.subscriptWrongIndex, PathExplorerError.subscriptMissingKey:
                return
            default:
                XCTFail("Wrong error for getting a non-exiting value: \(error). Should be 'subscriptWrongIndex' or 'subscriptMissingKey'")
            }
        }
    }

    func testPathExplorersDelete(path: Path, file: StaticString = #file, line: UInt = #line) {
        testDelete(path: path, explorer: json, file: file, line: line)
        testDelete(path: path, explorer: plist, file: file, line: line)
        testDelete(path: path, explorer: xml, file: file, line: line)
    }

    // MARK: - Add

    func testAdd<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        do {
            try explorer.add(value, at: path)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }

        testGet(path: path, explorer: explorer, value: value, file: file, line: line)
    }

    func testPathExplorersAdd<Value: KeyAllowedType>(path: Path, value: Value, file: StaticString = #file, line: UInt = #line) {
        testAdd(path: path, explorer: json, value: value, file: file, line: line)
        testAdd(path: path, explorer: plist, value: value, file: file, line: line)
        testAdd(path: path, explorer: xml, value: value, file: file, line: line)
    }
}
