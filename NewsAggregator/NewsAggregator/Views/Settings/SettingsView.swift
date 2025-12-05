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
                Section("Обновление") {
                    Picker("Автообновление", selection: $viewModel.refreshInterval) {
                        ForEach(RefreshInterval.allCases) { interval in
                            Text(interval.title).tag(interval.rawValue)
                        }
                    }
                }
                
                Section("Источники") {
                    ForEach(NewsSource.all) { source in // NewsSource.all загружается из NewsSources.plist
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
                            Text("Очистить кэш")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Настройки")
            .confirmationDialog("Очистить кэш?", isPresented: $showClearConfirmation) {
                Button("Очистить", role: .destructive) {
                    Task {
                        await viewModel.clearCache()
                    }
                }
            } message: {
                Text("Будут удалены все сохранённые новости и изображения")
            }
        }
    }
}
