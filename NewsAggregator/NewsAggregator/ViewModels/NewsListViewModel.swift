//
//  NewsListViewModel.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

// ViewModels/NewsListViewModel.swift
import Foundation
import SwiftUI

@MainActor
final class NewsListViewModel: ObservableObject {
    @Published private(set) var news: [NewsItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    @AppStorage("enabledSourceIDs") private var enabledSourceIDsData: Data = Data()
    
    private var enabledSourceIDs: Set<String> {
        (try? JSONDecoder().decode(Set<String>.self, from: enabledSourceIDsData))
            ?? Set(NewsSource.all.map(\.id))
    }
    
    private var enabledSources: [NewsSource] {
        NewsSource.all.filter { enabledSourceIDs.contains($0.id) }
    }
    
    private let rssService = RSSService()
    private let storage = NewsStorage()
    
    init() {
        news = storage.loadAll()
    }
    
    func refresh() async {
        isLoading = true
        error = nil
        
        do {
            let items = try await rssService.fetchAllNews(from: enabledSources)
            storage.save(items)
            news = storage.loadAll().filter { enabledSourceIDs.contains($0.sourceID) }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func markAsRead(_ item: NewsItem) {
        storage.markAsRead(id: item.id)
        if let index = news.firstIndex(where: { $0.id == item.id }) {
            news[index].isRead = true
        }
    }
}
