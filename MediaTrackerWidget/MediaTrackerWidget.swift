import WidgetKit
import SwiftUI

struct MediaEntry: TimelineEntry {
    let date: Date
    let items: [WidgetMediaItem]
}

struct MediaProvider: TimelineProvider {
    private var previewItems: [WidgetMediaItem] { [
        WidgetMediaItem(id: "p1", title: "Breaking Bad",   subtitle: "Crime Drama", imageUrl: nil, mediaTypeRaw: "TV",    statusRaw: "On Going",          rating: 9.5),
        WidgetMediaItem(id: "p2", title: "Dune: Part Two", subtitle: "Sci-Fi",      imageUrl: nil, mediaTypeRaw: "Movie", statusRaw: "Planning to Watch", rating: 8.5),
        WidgetMediaItem(id: "p3", title: "Jujutsu Kaisen", subtitle: "Action",      imageUrl: nil, mediaTypeRaw: "Anime", statusRaw: "On Going",          rating: 9.0),
    ] }

    private func loadedItems() -> [WidgetMediaItem] { Array(WidgetDataManager.load().prefix(3)) }

    func placeholder(in context: Context) -> MediaEntry { MediaEntry(date: .now, items: previewItems) }
    func getSnapshot(in context: Context, completion: @escaping (MediaEntry) -> Void) {
        completion(MediaEntry(date: .now, items: context.isPreview ? previewItems : loadedItems()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<MediaEntry>) -> Void) {
        let nextDay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86_400))
        completion(Timeline(entries: [MediaEntry(date: .now, items: loadedItems())], policy: .after(nextDay)))
    }
}

struct MediaTrackerWidget: Widget {
    let kind = "MediaTrackerWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MediaProvider()) { MediaTrackerWidgetView(entry: $0) }
            .configurationDisplayName("Watch List")
            .description("Your current media watch list.")
            .supportedFamilies([.systemMedium])
    }
}

struct MediaTrackerWidgetView: View {
    let entry: MediaEntry
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Watch List").font(.system(size: 11.5, weight: .bold, design: .rounded))
                Spacer()
                Text(entry.date, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                    .font(.system(size: 9, weight: .medium, design: .monospaced)).foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)

            VStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    if i < entry.items.count { MediaRow(item: entry.items[i]) } else { EmptySlotRow() }
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .containerBackground(.background, for: .widget)
    }
}

private struct MediaRow: View {
    let item: WidgetMediaItem
    private var ongoing: Bool { item.statusRaw == "On Going" }
    private var mediaIcon: String {
        switch item.mediaTypeRaw {
        case "Movie": "film"; case "TV": "tv"; case "Anime": "sparkles.tv"
        case "Manga": "book.closed"; case "Book": "book"; default: "play.circle"
        }
    }
    var body: some View {
        HStack(spacing: 9) {
            RoundedRectangle(cornerRadius: 2).fill(Color.primary).frame(width: 3, height: 28)
            Image(systemName: mediaIcon).font(.system(size: 11)).foregroundStyle(.secondary).frame(width: 14, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.system(size: 11.5, weight: .semibold, design: .rounded)).lineLimit(1)
                Text(item.subtitle).font(.system(size: 9)).foregroundStyle(.secondary).lineLimit(1)
            }
            Spacer(minLength: 4)
            Text(ongoing ? "Ongoing" : "Planned").font(.system(size: 8, weight: .medium)).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 6).padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

private struct EmptySlotRow: View {
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "plus.circle").font(.system(size: 10)).foregroundStyle(Color(UIColor.tertiaryLabel))
            Text("Add something to watch").font(.system(size: 9)).foregroundStyle(Color(UIColor.tertiaryLabel))
            Spacer()
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

#Preview(as: .systemMedium) {
    MediaTrackerWidget()
} timeline: {
    MediaEntry(date: .now, items: [
        WidgetMediaItem(id: "1", title: "Breaking Bad",   subtitle: "Crime Drama", imageUrl: nil, mediaTypeRaw: "TV",    statusRaw: "On Going",          rating: 9.5),
        WidgetMediaItem(id: "2", title: "Dune: Part Two", subtitle: "Sci-Fi",      imageUrl: nil, mediaTypeRaw: "Movie", statusRaw: "Planning to Watch", rating: 8.5),
        WidgetMediaItem(id: "3", title: "Jujutsu Kaisen", subtitle: "Action",      imageUrl: nil, mediaTypeRaw: "Anime", statusRaw: "On Going",          rating: 9.0),
    ])
    MediaEntry(date: .now, items: [])
}
