//
//  ImageCacheTests.swift
//  NewsAggregator
//
//  Created by Aleksandr Meshchenko on 04.12.25.
//

import Testing
import Foundation
@testable import NewsAggregator

@Suite("Image Cache Tests")
struct ImageCacheTests {
    
    let sut = ImageCache.shared
    
    init() async {
        await sut.clearCache()
    }
    
    @Test("Load image from network")
    func loadImageFromNetwork() async throws {
        let url = URL(string: "https://picsum.photos/100")!
        
        let image = await sut.image(for: url)
        
        #expect(image != nil, "Should load image from network")
    }
    
    @Test("Cache hit should be fast")
    func cacheHitAfterLoad() async throws {
        let url = URL(string: "https://picsum.photos/100")!
        
        // First load - network
        let firstLoad = await sut.image(for: url)
        #expect(firstLoad != nil)
        
        // Second load - cache
        let start = CFAbsoluteTimeGetCurrent()
        let secondLoad = await sut.image(for: url)
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        #expect(secondLoad != nil)
        #expect(elapsed < 0.1, "Cache hit should be fast, was \(elapsed)s")
    }
    
    @Test("Clear cache removes images")
    func clearCacheRemovesImages() async throws {
        let url = URL(string: "https://picsum.photos/100")!
        _ = await sut.image(for: url)
        
        await sut.clearCache()
        
        let start = CFAbsoluteTimeGetCurrent()
        _ = await sut.image(for: url)
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        #expect(elapsed > 0.05, "Should reload from network after cache clear")
    }
    
    @Test("Invalid URL returns nil")
    func invalidURLReturnsNil() async {
        let url = URL(string: "https://invalid.invalid/404.jpg")!
        
        let image = await sut.image(for: url)
        
        #expect(image == nil)
    }
    
    @Test("Concurrent loads all succeed")
    func concurrentLoadsReturnSameImage() async throws {
        let url = URL(string: "https://picsum.photos/100")!
        
        async let image1 = sut.image(for: url)
        async let image2 = sut.image(for: url)
        async let image3 = sut.image(for: url)
        
        let results = await [image1, image2, image3]
        
        #expect(results.allSatisfy { $0 != nil })
    }
}
