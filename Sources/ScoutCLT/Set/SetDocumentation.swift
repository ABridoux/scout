//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import ArgumentParser
import Lux

enum SetDocumentation: Documentation {
    private static let xmlInjector = XMLEnhancedInjector(type: .terminal)

    private static let xmlExample =
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset>
        <url>
            <loc>https://your-website-url.com/posts</loc>
            <changefreq>daily</changefreq>
            <priority>1.0</priority>
            <lastmod>2020-03-10</lastmod>
        </url>
        <url>
            <loc>https://your-website-url.com/posts/first-post</loc>
            <changefreq>monthly</changefreq>
            <priority>0.5</priority>
            <lastmod>2020-03-10</lastmod>
        </url>
    </urlset>
    """

    private static let examples =
        [(#"`scout set "[1].changefreq=yearly"`"#, #"will change the second url #changefreq# key value to "yearly""#),
        (#"`scout set "[0].priority"=2.0`"#, #"will change the first url #priority# key value to 2.0"#),
        (#"`scout set "[1].changefreq=yearly"` "urlset[0].priority=2.0"`"#, #"will change both the second url #changefreq# key value to "yearly"\#n and the first url #priority# key value to 2.0"#),
        (#"`scout set "[-1].priority=2.0"`"#, #"will change the last url #priority# key value to 2.0"#),
        (#"`scout set "[0].changefreq=#frequence#"`"#, #"will change the first url #changefreq# key name to #frequence#"#),
        (#"`scout set "[0].priority=/2.0/"`"#, #"will change the first url #priority# key value to the String value "2.0""#),
        (#"`scout set "[0].priority=~2~"`"#, #"will change the first url #priority# key value to the Real value 2 (Plist only)"#),
        (#"`scout set "[0].priority=1" -e json`"#, #"will set the value and convert the modified data to a JSON format"#)]

    static let text =
    """

    -----------
    Set command
    -----------

    \(SetCommand.configuration.abstract)

    \(notesHeader)

    \(commonDoc)

    \(header: "Several paths")
    It's possible to set multiple values in one command by specifying several path/value pairs.

    \(bold: "Set key name")
    Enclose the value with sharp signs to change the key name: #keyName#.

    \(forceTypeDoc)

    \(miscDoc)

    \(examplesHeader)

    Xml file

    \(xmlInjector.inject(in: xmlExample))

    \(examplesText(from: examples))
    """
}
