//
//  NewsRowView.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 02.12.25.
//

// Views/NewsList/NewsRowView.swift
import SwiftUI

enum DisplayMode {
    case compact
    case expanded
    
    mutating func toggle() {
        self = self == .compact ? .expanded : .compact
    }
}

struct NewsRowView: View {
    let item: NewsItem
    let mode: DisplayMode
    
    private var displayImageURL: URL? {
        item.imageURL ?? NewsSource.find(by: item.sourceID)?.logoURL
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CachedAsyncImage(url: displayImageURL)
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(mode == .compact ? 2 : nil)
                
                if mode == .expanded, let summary = item.summary {
                    Text(summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                HStack {
                    Text(NewsSource.find(by: item.sourceID)?.name ?? item.sourceID)
                    Spacer()
                    Text(item.publishedAt, style: .relative)
                }
                .font(.caption)
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
        .opacity(item.isRead ? 0.6 : 1.0)
    }
}
