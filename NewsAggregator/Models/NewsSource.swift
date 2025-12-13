//
//  NewsSource.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

// Models/NewsSource.swift
import Foundation

struct NewsSource: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let feedURL: URL
    let logoURL: URL?
}

extension NewsSource: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id, name, feedURL, logoURL
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let feedURLString = try container.decode(String.self, forKey: .feedURL)
        guard let feedURL = URL(string: feedURLString) else {
            throw DecodingError.dataCorruptedError(forKey: .feedURL, in: container, debugDescription: "Invalid URL")
        }
        self.feedURL = feedURL
        
        if let logoURLString = try container.decodeIfPresent(String.self, forKey: .logoURL) {
            self.logoURL = URL(string: logoURLString)
        } else {
            self.logoURL = nil
        }
    }
}

extension NewsSource {
    
    static let all: [NewsSource] = {
        guard let url = Bundle.main.url(forResource: "NewsSources", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let sources = try? PropertyListDecoder().decode([NewsSource].self, from: data)
        else {
            return []
        }
        return sources
    }()
    
    static func find(by id: String) -> NewsSource? {
        all.first { $0.id == id }
    }
}
