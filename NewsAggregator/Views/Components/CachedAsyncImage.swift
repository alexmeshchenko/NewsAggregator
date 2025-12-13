//
//  CachedAsyncImage.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 02.12.25.
//

// Views/Components/CachedAsyncImage.swift
import SwiftUI

struct CachedAsyncImage: View {
    let url: URL?
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            }
        }
        .task(id: url) {
            guard let url, image == nil else { return }
            isLoading = true
            image = await ImageCache.shared.image(for: url)
            isLoading = false
        }
    }
}
