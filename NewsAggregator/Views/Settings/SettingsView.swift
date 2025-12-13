//
//  SettingsView.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 03.12.25.
//


import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Renewing") {
                    Picker("Auto-updating", selection: $viewModel.refreshInterval) {
                        ForEach(RefreshInterval.allCases) { interval in
                            Text(interval.title).tag(interval.rawValue)
                        }
                    }
                }
                
                Section("Sources") {
                    ForEach(NewsSource.all) { source in // NewsSource.all loads from NewsSources.plist
                        Toggle(source.name, isOn: Binding(
                            get: { viewModel.isSourceEnabled(source) },
                            set: { _ in viewModel.toggleSource(source) }
                        ))
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        HStack {
                            Text("Clear cache")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Clear the cache?", isPresented: $showClearConfirmation) {
                Button("Clean", role: .destructive) {
                    Task {
                        await viewModel.clearCache()
                    }
                }
            } message: {
                Text("All saved news and images will be deleted")
            }
        }
    }
}
