import SwiftUI
import TMDb
import SwiftData
import Foundation

@main
struct MediaTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Review.self,
            ArchiveItem.self
        ])
    }
}

extension TMDbClient {
    static let shared = TMDbClient(apiKey: Config.TMDBAPIKEY)
}
