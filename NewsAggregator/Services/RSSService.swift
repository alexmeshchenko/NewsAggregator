//
//  RSSService.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

import Foundation

actor RSSService {
    
    func fetchNews(from source: NewsSource) async throws -> [NewsItem] {
        let (data, _) = try await URLSession.shared.data(from: source.feedURL)
        
        let parser = RSSParser(sourceID: source.id)
        return try parser.parse(data)
    }
    
    func fetchAllNews(from sources: [NewsSource]) async throws -> [NewsItem] {
        await withTaskGroup(of: [NewsItem].self) { group in
            for source in sources {
                group.addTask {
                    do {
                        return try await self.fetchNews(from: source)
                    } catch {
                        print("Failed to fetch \(source.name): \(error)")
                        return []
                    }
                }
            }
            
            var allNews: [NewsItem] = []
            for await items in group {
                allNews.append(contentsOf: items)
            }
            
            return allNews.sorted { $0.publishedAt > $1.publishedAt }
        }
    }
}

// MARK: - RSS Parser

final class RSSParser: NSObject, XMLParserDelegate {
    private let sourceID: String
    private var items: [NewsItem] = []
    
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    private var currentImageURL: String?
    private var isInsideItem = false
    
    init(sourceID: String) {
        self.sourceID = sourceID
    }
    
    func parse(_ data: Data) throws -> [NewsItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        
        if !parser.parse() {
            print("Parse error: \(parser.parserError?.localizedDescription ?? "unknown")")
            throw RSSError.parsingFailed(parser.parserError)
        }
        
        print("Parsed items: \(items.count)")
        return items
    }
    
    // MARK: - XMLParserDelegate
    
    // Parser is looking for pictures in enclosure and media:content
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        
        if elementName == "item" {
            isInsideItem = true
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDate = ""
            currentImageURL = nil
        }
        
        // Image can be in enclosure or media:content
        if isInsideItem {
            
            if elementName == "enclosure",
               let type = attributeDict["type"], type.hasPrefix("image"),
               let url = attributeDict["url"] {
                currentImageURL = url
            }
            if elementName == "media:content",
               let url = attributeDict["url"] {
                currentImageURL = url
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard isInsideItem else { return }
        
        switch currentElement {
        case "title": currentTitle += string
        case "link": currentLink += string
        case "description": currentDescription += string
        case "pubDate": currentPubDate += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        guard elementName == "item", isInsideItem else { return }
        
        isInsideItem = false
        
        let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let link = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty, let linkURL = URL(string: link) else { return }
        
        let item = NewsItem(
            id: "\(sourceID)-\(link)",
            sourceID: sourceID,
            title: title,
            summary: cleanHTML(currentDescription),
            imageURL: currentImageURL.flatMap { URL(string: $0) },
            link: linkURL,
            publishedAt: parseDate(currentPubDate) ?? Date(),
            isRead: false
        )
        
        items.append(item)
    }
    
    // MARK: - Helpers
    
    // Clean HTML tags from description
    private func cleanHTML(_ string: String) -> String? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        // Delete HTML tags
        let cleaned = trimmed.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseDate(_ string: String) -> Date? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // RFC 822 - standard RSS format
        let formatters: [DateFormatter] = [
            Self.rfc822Formatter,
            Self.rfc822FormatterAlt
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        
        return nil
    }
    
    private static let rfc822Formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    private static let rfc822FormatterAlt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

// MARK: - Errors

enum RSSError: Error {
    case parsingFailed(Error?)
}
