# NewsAggregator

RSS news aggregator from multiple sources.

## Features

- Display news from multiple sources in a unified list
- Sorted by publication date
- Two display modes: compact and expanded
- Read status tracking
- Auto-refresh timer (configurable)
- Enable/disable sources
- Image caching (memory + disk)
- Offline access to loaded news

## Architecture

**MVVM** with layer separation:
```
├── Models/          # Domain models and Realm entities
├── Services/        # RSS parsing, storage, image cache
├── ViewModels/      # Presentation logic
├── Views/           # SwiftUI screens
└── Resources/       # Source configuration (plist)
```

## Technologies

- **Swift 6**, iOS 16+
- **SwiftUI** - UI
- **Realm** - local news storage
- **XMLParser** - RSS parsing

## Scalability

Adding a new source — single entry in `NewsSources.plist`:
```xml
<dict>
    <key>id</key>
    <string>new_source</string>
    <key>name</key>
    <string>New Source</string>
    <key>feedURL</key>
    <string>https://example.com/rss</string>
    <key>logoURL</key>
    <string>https://example.com/logo.png</string>
</dict>
```

No recompilation needed when modifying plist at runtime (for debug).

## Tests

- `ImageCacheTests` — caching, clearing, concurrent access
- `RSSParserTests` — XML parsing, HTML handling in descriptions