//
//  SettingsViewModel.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 03.12.25.
//

import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("refreshInterval") var refreshInterval: Int = RefreshInterval.off.rawValue
    @AppStorage("enabledSourceIDs") private var enabledSourceIDsData: Data = Data()
    
    var enabledSourceIDs: Set<String> {
        get {
            (try? JSONDecoder().decode(Set<String>.self, from: enabledSourceIDsData)) 
                ?? Set(NewsSource.all.map(\.id))
        }
        set {
            enabledSourceIDsData = (try? JSONEncoder().encode(newValue)) ?? Data()
            objectWillChange.send()
        }
    }
    
    func isSourceEnabled(_ source: NewsSource) -> Bool {
        enabledSourceIDs.contains(source.id)
    }
    
    func toggleSource(_ source: NewsSource) {
        var ids = enabledSourceIDs
        if ids.contains(source.id) {
            ids.remove(source.id)
        } else {
            ids.insert(source.id)
        }
        enabledSourceIDs = ids
    }
    
    func clearCache() async {
        await ImageCache.shared.clearCache()
        NewsStorage().clearAll()
    }
}
