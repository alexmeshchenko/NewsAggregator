//
//  NewsListView.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 30.11.25.
//

// Views/NewsList/NewsListView.swift
import SwiftUI

struct NewsListView: View {
    @StateObject private var viewModel = NewsListViewModel()
    @State private var displayMode: DisplayMode = .compact
    @State private var showSettings = false
    @AppStorage("refreshInterval") private var refreshInterval: Int = 0
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.news.isEmpty {
                    ProgressView("Loading...")
                } else if let error = viewModel.error, viewModel.news.isEmpty {
                    ContentUnavailableView(
                        "Failed to Load",
                        systemImage: "exclamationmark.triangle",
                        description: Text(error.localizedDescription)
                    )
                } else {
                    newsList
                }
            }
            .navigationTitle("News")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.snappy) {
                            displayMode.toggle()
                        }
                    } label: {
                        Image(systemName: displayMode == .compact
                            ? "rectangle.expand.vertical"
                            : "rectangle.compress.vertical")
                    }
                }
            }
            .task {
                await viewModel.refresh()
            }
            .task(id: refreshInterval) {
                guard refreshInterval > 0 else { return }
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(refreshInterval))
                    await viewModel.refresh()
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .onChange(of: showSettings) { _, isShowing in
                if !isShowing {
                    Task { await viewModel.refresh() }
                }
            }
        }
    }
    
    private var newsList: some View {
        List(viewModel.news) { item in
            NewsRowView(item: item, mode: displayMode)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.markAsRead(item)
                    openURL(item.link)
                }
        }
    }
}
