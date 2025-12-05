//
//  AppSettings.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 03.12.25.
//

import Foundation

enum RefreshInterval: Int, CaseIterable, Identifiable {
    case off = 0
    case oneMinute = 60
    case fiveMinutes = 300
    case fifteenMinutes = 900
    case thirtyMinutes = 1800
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .off: "Выкл"
        case .oneMinute: "1 мин"
        case .fiveMinutes: "5 мин"
        case .fifteenMinutes: "15 мин"
        case .thirtyMinutes: "30 мин"
        }
    }
}
