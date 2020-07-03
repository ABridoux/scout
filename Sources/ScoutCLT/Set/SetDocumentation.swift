import ArgumentParser
import Lux

struct SetDocumentation: Documentation {
    private static let xmlInjector = XMLEnhancedInjector(type: .terminal)
    private static let zshInjector = ZshInjector(type: .terminal)

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

    private static let examples = [(#"`scout set "urlset[1].changefreq=yearly"`"#, #"will change the second url #changefreq# key value to "yearly""#),
                                   (#"`scout set "urlset[0].priority"=2.0`"#, #"will change the first url #priority# key value to 2.0"#),
                                   (#"`scout set "urlset[1].changefreq=yearly"` "urlset[0].priority=2.0"`"#,  """
                                                                                                            will change both the second url #changefreq# key value to "yearly"
                                                                                                                and the first url #priority# key value to 2.0
                                                                                                            """),
                                   (#"`scout set "urlset[-1].priority=2.0"`"#, #"will change the last url #priority# key value to 2.0"#),
                                   (#"`scout set "urlset[0].changefreq=#frequence#""#, #"will change the first url #changefreq# key name to #frequence#"#),
                                   (#"`scout set "urlset[0].priority=/2.0/"`"#, #"will change the first url #priority# key value to the String value "2.0""#),
                                   (#"`scout set "urlset[0].priority=~2~"`"#, #"will change the first url #priority# key value to the Real value 2 (Plist only)"#)]

    static let text =
    """

    Set command
    ============

    Notes
    -----
    - You can set multiple values in one command.
    - Specify the \(zshInjector.delegate.inject(.optionNameOrFlag, in: .terminal, "-v")) flag to see the modified data
    
    - If the path is invalid, the program will return an error
    - Enclose the value with sharp signs to change the key name: #keyName#
    - Enclose the value with slash signs to force the value as a string: /valueAsString/ (Plist, Json)
    - Enclose the value with interrogative signs to force the value as a boolean: ?valueToBoolean? (Plist, Json)
    - Enclose the value with tilde signs to force the value as a real: ~valueToReal~ (Plist)
    - Enclose the value with chevron signs to force the value as a integer: <valueToInteger> (Plist)
    - When accessing an array value by its index, use the index -1 to access to the last element

    Examples
    --------

    Xml file
    
    \(xmlInjector.inject(in: xmlExample))

    \(examplesText(from: examples))
    """
}
