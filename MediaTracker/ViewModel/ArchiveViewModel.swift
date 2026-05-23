import SwiftData
import SwiftUI

@MainActor
final class ArchiveViewModel {
    enum SortOrder: String, CaseIterable, Identifiable {
        case dateAdded = "Date Added"
        case title = "Title"
        var id: String { rawValue }
    }

    func addOrUpdate(_ result: SearchResult, status: WatchStatus, context: ModelContext) {
        let mediaPrefix = result.subtitle.components(separatedBy: " ·").first ?? "item"
        let compositeId = "\(mediaPrefix.lowercased())-\(result.title.lowercased().filter { !$0.isWhitespace })"
        let resolvedImageUrl: String?
        if let path = result.posterPath {
            resolvedImageUrl = "https://image.tmdb.org/t/p/w92\(path)"
        } else if let url = result.imageUrl {
            resolvedImageUrl = url.replacingOccurrences(of: "http://", with: "https://")
        } else {
            resolvedImageUrl = nil
        }

        let descriptor = FetchDescriptor<Archive>(predicate: #Predicate { $0.compositeId == compositeId })
        let existing = try? context.fetch(descriptor).first

        if let existing {
            existing.status = status
            if existing.imageUrl == nil {
                existing.imageUrl = resolvedImageUrl
            }
        } else {
            context.insert(Archive(
                compositeId: compositeId,
                title: result.title,
                subtitle: result.subtitle,
                imageUrl: resolvedImageUrl,
                rating: result.rating,
                mediaType: MediaType(rawValue: mediaPrefix) ?? .movie,
                status: status
            ))
        }
        save(context: context)
    }

    func updateStatus(of item: Archive, to status: WatchStatus, context: ModelContext) {
        item.status = status
        save(context: context)
    }

    func delete(_ item: Archive, context: ModelContext) {
        context.delete(item)
        save(context: context)
    }

    private func save(context: ModelContext) {
        do {
            try context.save()
            syncWidget(context: context)
        } catch {
            print("Save error:", error)
        }
    }

    private func syncWidget(context: ModelContext) {
        let descriptor = FetchDescriptor<Archive>()
        let all = (try? context.fetch(descriptor)) ?? []
        WidgetDataManager.save(all.map { $0.toWidgetItem() })
    }
}
