//
//  ImageCache.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 02.12.25.
//

// Services/ImageCache.swift
import UIKit

actor ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL // диск: Caches/ImageCache/
    
    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0] // Library/Caches/
        cacheDirectory = caches.appendingPathComponent("ImageCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func image(for url: URL) async -> UIImage? {
        let key = cacheKey(for: url)
        
        // 1. Memory
        if let cached = memoryCache.object(forKey: key as NSString) {
            print("Memory cache hit: \(url.lastPathComponent)")
            return cached
        }
        
        // 2. Disk
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            print("Disk cache hit: \(url.lastPathComponent)")
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        
        // 3. Network
        print("- Loading: \(url)")
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP \(httpResponse.statusCode): \(url.lastPathComponent)")
            }
            
            guard let image = UIImage(data: data) else {
                print("Invalid image data: \(url)")
                return nil
            }
            
            // Save
            memoryCache.setObject(image, forKey: key as NSString)
            try? data.write(to: fileURL)
            print("Loaded & cached: \(url.lastPathComponent)")
            return image
            
        } catch {
            print("Failed to load: \(url) - \(error.localizedDescription)")
            return nil
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    private func cacheKey(for url: URL) -> String {
        url.absoluteString.data(using: .utf8)!
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
    }
}
