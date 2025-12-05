//
//  RealmModels.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 02.12.25.
//


import Foundation
import RealmSwift

final class RealmNewsItem: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var sourceID: String
    @Persisted var title: String
    @Persisted var summary: String?
    @Persisted var imageURL: String?
    @Persisted var link: String
    @Persisted var publishedAt: Date
    @Persisted var isRead: Bool = false
}

// MARK: - Mapping

extension RealmNewsItem {
    
    convenience init(from item: NewsItem) {
        self.init()
        self.id = item.id
        self.sourceID = item.sourceID
        self.title = item.title
        self.summary = item.summary
        self.imageURL = item.imageURL?.absoluteString
        self.link = item.link.absoluteString
        self.publishedAt = item.publishedAt
        self.isRead = item.isRead
    }
    
    func toNewsItem() -> NewsItem {
        NewsItem(
            id: id,
            sourceID: sourceID,
            title: title,
            summary: summary,
            imageURL: imageURL.flatMap { URL(string: $0) },
            link: URL(string: link)!,
            publishedAt: publishedAt,
            isRead: isRead
        )
    }
}
