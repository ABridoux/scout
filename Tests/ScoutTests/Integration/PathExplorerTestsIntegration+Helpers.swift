import XCTest
import Scout

extension PathExplorerTestsIntegration {

    // MARK: - Get

    func testGet<Explorer: PathExplorer, Value: KeyAllowedType>(path: Path, explorer: Explorer, value: Value, file: StaticString = #file, line: UInt = #line) {
        do {
            let foundValue = try explorer.get(path, as: .init(Value.self))
            XCTAssertEqual(value, foundValue)
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

    func testPathExplorersSet<Explorer: PathExplorer>(path: Path, explorer: Explorer, keyName: String, file: StaticString = #file, line: UInt = #line) {
        var explorer = explorer
        do {
            let value = try explorer.get(path).stringValue
            try explorer.set(path, keyNameTo: keyName)
            XCTAssertEqual(value, try explorer.get(path).stringValue)
        } catch {
            XCTFail("\(explorer.format): \(error.localizedDescription)", file: file, line: line)
            return
        }
    }

    func testPathExplorersSet(path: Path, keyName: String, file: StaticString = #file, line: UInt = #line) {
        testPathExplorersSet(path: path, explorer: json, keyName: keyName, file: file, line: line)
        testPathExplorersSet(path: path, explorer: plist, keyName: keyName, file: file, line: line)
        testPathExplorersSet(path: path, explorer: xml, keyName: keyName, file: file, line: line)
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
