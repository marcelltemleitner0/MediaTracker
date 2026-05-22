import Foundation
import WidgetKit

struct WidgetMediaItem: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let imageUrl: String?
    let mediaTypeRaw: String
    let statusRaw: String
    let rating: Double
}

enum WidgetDataManager {
    static let appGroupID = "group.MT.MediaTracker"
    static let itemsKey   = "widgetMediaItems"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    static func save(_ items: [WidgetMediaItem]) {
        guard let encoded = try? JSONEncoder().encode(items) else { return }
        defaults?.set(encoded, forKey: itemsKey)
        WidgetCenter.shared.reloadTimelines(ofKind: "MediaTrackerWidget")
    }

    static func load() -> [WidgetMediaItem] {
        guard
            let data  = defaults?.data(forKey: itemsKey),
            let items = try? JSONDecoder().decode([WidgetMediaItem].self, from: data)
        else { return [] }
        return items
    }
}
