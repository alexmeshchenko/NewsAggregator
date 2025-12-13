//
//  NewsItem.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

// Models/NewsItem.swift
import Foundation

/*
 Sendable везде - для Swift 6 concurrency
 В NewsItem храню sourceID вместо полного NewsSource - проще для Realm потом
 Источники захардкожены как static - для MVP достаточно
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
