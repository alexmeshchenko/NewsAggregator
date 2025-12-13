//
//  NewsStorage.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 02.12.25.
//


import Foundation
import RealmSwift

@MainActor
final class NewsStorage {
    
    private var realm: Realm {
        try! Realm()
    }
    
    func save(_ items: [NewsItem]) {
        let realmItems = items.map { item -> RealmNewsItem in
            // Keep existing isRead status
            let existingItem = realm.object(ofType: RealmNewsItem.self, forPrimaryKey: item.id)
            let realmItem = RealmNewsItem(from: item)
            realmItem.isRead = existingItem?.isRead ?? false
            return realmItem
        }
        
        try? realm.write {
            realm.add(realmItems, update: .modified)
        }
    }
    
    func loadAll() -> [NewsItem] {
        realm.objects(RealmNewsItem.self)
            .sorted(byKeyPath: "publishedAt", ascending: false)
            .map { $0.toNewsItem() }
    }
    
    func markAsRead(id: String) {
        guard let item = realm.object(ofType: RealmNewsItem.self, forPrimaryKey: id) else { return }
        try? realm.write {
            item.isRead = true
        }
    }
    
    func clearAll() {
        try? realm.write {
            realm.delete(realm.objects(RealmNewsItem.self))
        }
    }
}
