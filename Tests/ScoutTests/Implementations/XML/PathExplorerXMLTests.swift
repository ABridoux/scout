//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import XCTest
import AEXML
@testable import Scout

final class PathExplorerXMLTests: XCTestCase {

    // MARK: - Constants

    struct Character: Encodable {
        let name: String
        let quote: String
        var episodes = [1, 2, 3]

        static let woody = Character(name: "Woody", quote: "I got a snake in my boot")
        static let buzz = Character(name: "Buzz", quote: "To infinity and beyond")
        static let zurg = Character(name: "Zurg", quote: "Destroy Buzz Lightyear")

        static let toybox = [woody, buzz, zurg]

        static var charactersByName = ["Woody": woody, "Buzz": buzz, "Zurg": zurg]
    }

    let stubData1: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "root")
        root.addChild(.init(name: "stringValue", value: "Hello", attributes: [:]))
        root.addChild(.init(name: "boolValue", value: "false", attributes: [:]))
        document.addChild(root)

        return document.xml.data(using: .utf8)!
    }()

    let stubData2: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "root")
        let dogs = AEXMLElement(name: "dogs")
        dogs.addChildren([.init(name: "dog", value: "Villy", attributes: [:]),
                          .init(name: "dog", value: "Spot", attributes: [:]),
                          .init(name: "dog", value: "Betty", attributes: [:])
                        ])
        root.addChild(dogs)
        document.addChild(root)

        return document.xml.data(using: .utf8)!
    }()

    var toyBox: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "toybox")
        document.addChild(root)
        let characters = AEXMLElement(name: "characters")
        root.addChild(characters)
        Character.toybox.forEach { character in
            let characterElement = AEXMLElement(name: "character")
            characterElement.addChild(name: "name", value: character.name)
            characterElement.addChild(name: "quote", value: character.quote)
            let episodes = AEXMLElement(name: "episodes")
            episodes.addChild(name: "episode", value: "1")
            episodes.addChild(name: "episode", value: "2")
            episodes.addChild(name: "episode", value: "3")
            characterElement.addChild(episodes)
            characters.addChild(characterElement)
        }

        return document.xml.data(using: .utf8)!
    }()

    var toyBoxByName: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "toybox")
        document.addChild(root)
        let characters = AEXMLElement(name: "characters")
        root.addChild(characters)
        Character.toybox.forEach { character in
            let characterElement = AEXMLElement(name: character.name)
            characterElement.addChild(name: "name", value: character.name)
            characterElement.addChild(name: "quote", value: character.quote)
            let episodes = AEXMLElement(name: "episodes")
            episodes.addChild(name: "episode", value: "1")
            episodes.addChild(name: "episode", value: "2")
            episodes.addChild(name: "episode", value: "3")
            characterElement.addChild(episodes)
            characters.addChild(characterElement)
        }

        return document.xml.data(using: .utf8)!
    }()

    var toyBoxWithOneEpisode: Data = {
        let document = AEXMLDocument()
        let root = AEXMLElement(name: "toybox")
        document.addChild(root)
        let characters = AEXMLElement(name: "characters")
        root.addChild(characters)
        Character.toybox.forEach { character in
            let characterElement = AEXMLElement(name: "character")
            characterElement.addChild(name: "name", value: character.name)
            characterElement.addChild(name: "quote", value: character.quote)
            let episodes = AEXMLElement(name: "episodes")
            episodes.addChild(name: "episode", value: "1")
            characterElement.addChild(episodes)
            characters.addChild(characterElement)
        }

        return document.xml.data(using: .utf8)!
    }()

    // MARK: - Functions

    func testInitNotThrows() {
        XCTAssertNoThrow(try Xml(data: stubData1))
    }

    // MARK: Folded

    func testFolded() throws {
        var xml = try Xml(data: toyBox)

        xml.fold(upTo: 2)

        let value = try xml.get("characters", 0, "episodes", 0).string

        XCTAssertEqual(value, "~~SCOUT_FOLDED~~")
    }
}
