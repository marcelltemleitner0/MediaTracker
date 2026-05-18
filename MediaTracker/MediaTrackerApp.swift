import SwiftUI
import SwiftData

@main
struct MediaTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Movie.self,
            Series.self,
            Anime.self,
            Manga.self,
            Book.self,
            Review.self,
            ArchiveItem.self
        ])
    }
}
