//
//  RSSParserTests.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 04.12.25.
//

import Testing
@testable import NewsAggregator

@Suite("RSS Parser Tests")
struct RSSParserTests {
    
    @Test("Parse valid RSS item")
    func parseValidRSS() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <item>
                <title>Test Title</title>
                <link>https://example.com/news/1</link>
                <description>Test description</description>
                <pubDate>Mon, 02 Dec 2025 12:00:00 +0300</pubDate>
                <enclosure url="https://example.com/image.jpg" type="image/jpeg"/>
            </item>
        </channel>
        </rss>
        """
        let data = xml.data(using: .utf8)!
        let parser = RSSParser(sourceID: "test")
        
        let items = try parser.parse(data)
        
        #expect(items.count == 1)
        #expect(items[0].title == "Test Title")
        #expect(items[0].link.absoluteString == "https://example.com/news/1")
        #expect(items[0].imageURL?.absoluteString == "https://example.com/image.jpg")
    }
    
    @Test("Parse multiple items")
    func parseMultipleItems() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <item>
                <title>First</title>
                <link>https://example.com/1</link>
                <pubDate>Mon, 02 Dec 2025 12:00:00 +0300</pubDate>
            </item>
            <item>
                <title>Second</title>
                <link>https://example.com/2</link>
                <pubDate>Mon, 02 Dec 2025 13:00:00 +0300</pubDate>
            </item>
        </channel>
        </rss>
        """
        let data = xml.data(using: .utf8)!
        let parser = RSSParser(sourceID: "test")
        
        let items = try parser.parse(data)
        
        #expect(items.count == 2)
    }
    
    @Test("Strip HTML from description")
    func parseHTMLInDescription() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <item>
                <title>Test</title>
                <link>https://example.com/1</link>
                <description><![CDATA[<p>Text with <b>HTML</b> tags</p>]]></description>
                <pubDate>Mon, 02 Dec 2025 12:00:00 +0300</pubDate>
            </item>
        </channel>
        </rss>
        """
        let data = xml.data(using: .utf8)!
        let parser = RSSParser(sourceID: "test")
        
        let items = try parser.parse(data)
        
        #expect(items[0].summary == "Text with HTML tags")
    }
    
    @Test("Handle missing optional fields")
    func handleMissingOptionalFields() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <rss version="2.0">
        <channel>
            <item>
                <title>Minimal Item</title>
                <link>https://example.com/1</link>
                <pubDate>Mon, 02 Dec 2025 12:00:00 +0300</pubDate>
            </item>
        </channel>
        </rss>
        """
        let data = xml.data(using: .utf8)!
        let parser = RSSParser(sourceID: "test")
        
        let items = try parser.parse(data)
        
        #expect(items.count == 1)
        #expect(items[0].summary == nil)
        #expect(items[0].imageURL == nil)
    }
}
