//
//  File.swift
//  
//
//  Created by Alexis Bridoux on 14/03/2020.
//

import Foundation
import PathExplorer

do {
    let data = try Data(contentsOf: URL(fileURLWithPath: ""))
    let xml = try PathExplorerFactory.make(Xml.self, from: data)
}

