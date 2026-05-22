import SwiftData
import SwiftUI
import Combine

@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published var items: [Archive] = []
    @Published var selectedStatus: WatchStatus? = nil
    @Published var selectedMediaType: MediaType? = nil
    @Published var searchText: String = ""
    @Published var sortOrder: SortOrder = .dateAdded

    enum SortOrder: String, CaseIterable, Identifiable {
        case dateAdded = "Date Added"
        case title = "Title"
        var id: String { rawValue }
    }

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetch()
    }
    func fetch() {
        let descriptor = FetchDescriptor<Archive>(
            sortBy: fetchSortDescriptors()
        )
        items = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchSortDescriptors() -> [SortDescriptor<Archive>] {
        switch sortOrder {
        case .dateAdded: return [SortDescriptor(\.dateAdded, order: .reverse)]
        case .title:     return [SortDescriptor(\.title)]
      
        }
    }

    func add(_ item: Archive) {
        modelContext.insert(item)
        save()
    }

    func updateStatus(of item: Archive, to status: WatchStatus) {
        item.status = status
        save()
    }

    func delete(_ item: Archive) {
        modelContext.delete(item)
        save()
    }

    func delete(at offsets: IndexSet, in list: [Archive]) {
        offsets.map { list[$0] }.forEach { modelContext.delete($0) }
        save()
    }

    private func save() {
        do {
            try modelContext.save()
            fetch()

            let widgetItems = items.map { $0.toWidgetItem() }
            WidgetDataManager.save(widgetItems)

        } catch {
            print("Save error:", error)
        }
    }
}
