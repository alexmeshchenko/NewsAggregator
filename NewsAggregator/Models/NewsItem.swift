//
//  NewsItem.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

// Models/NewsItem.swift
import Foundation

/*
 Sendable everywhere - for Swift 6 concurrency
 NewsItem stores sourceID instead of full NewsSource - simpler for Realm mapping
 Sources are hardcoded as static - sufficient for MVP
 */
struct NewsItem: Identifiable, Sendable {
    let id: String
    let sourceID: String
    let title: String
    let summary: String?
    let imageURL: URL?
    let link: URL
    let publishedAt: Date
    var isRead: Bool = false
}
