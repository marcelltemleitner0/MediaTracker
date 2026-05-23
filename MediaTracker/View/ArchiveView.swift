import SwiftData
import SwiftUI

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = ArchiveViewModel()
    @State private var selectedTabId: String = "All"
    @Query(sort: \Archive.dateAdded, order: .reverse) private var items: [Archive]

    private var archiveTabs: [TabItem] {
        let allTab = TabItem("All", icon: "square.stack.fill", color: .blue)
        let statusTabs = WatchStatus.allCases.map {
            TabItem($0.rawValue, icon: $0.icon, color: $0.color)
        }
        return [allTab] + statusTabs
    }

    private var selectedStatus: WatchStatus? {
        WatchStatus.allCases.first { $0.rawValue == selectedTabId }
    }

    private var filtered: [Archive] {
        items.filter { selectedStatus == nil || $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabBarPill(tabs: archiveTabs, selectedId: $selectedTabId)

                Divider()

                ScrollView {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            selectedStatus == nil ? "No Archive Yet" : "Nothing \(selectedTabId)",
                            systemImage: selectedStatus == nil
                                ? "square.stack.fill"
                                : (selectedStatus?.icon ?? "square.stack.fill"),
                            description: Text(
                                selectedStatus == nil
                                    ? "Items you archive will appear here"
                                    : "Nothing marked as \"\(selectedTabId)\" yet"
                            )
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { item in
                                ArchiveCard(item: item) {
                                    vm.delete(item, context: modelContext)
                                } onStatusChange: { newStatus in
                                    vm.updateStatus(of: item, to: newStatus, context: modelContext)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationTitle("Archive")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ArchiveCard: View {
    let item: Archive
    let onDelete: () -> Void
    let onStatusChange: (WatchStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                AsyncImage(url: item.imageUrl.flatMap { URL(string: $0) }) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        PosterPlaceholder()
                    }
                }
                .frame(width: 52, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(2)
                    Text(item.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(.orange)
                        Text(String(format: "%.1f", item.rating))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                }

                Spacer()

                Image(systemName: item.status.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(item.status.color)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 14)

            HStack {
                Text(item.status.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(item.status.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(item.status.color.opacity(0.10), in: Capsule())
                Spacer()
                Text(item.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .contextMenu {
            ForEach(WatchStatus.allCases.filter { $0 != item.status }, id: \.self) { s in
                Button {
                    onStatusChange(s)
                } label: {
                    Label(s.rawValue, systemImage: s.icon)
                }
            }
            Divider()
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Archive.self, configurations: config)

    let samples: [(String, String, String?, Double, MediaType, WatchStatus)] = [
        ("Interstellar", "Movie · 2014-11-06", "https://image.tmdb.org/t/p/original/yQvGrMoipbRoddT0ZR8tPoR7NfX.jpg", 9.2, .movie, .watched),
        ("Attack on Titan", "Anime · 2013-01-01", "https://cdn.myanimelist.net/images/anime/1907/134102l.jpg?_gl=1*yiysm6*_gcl_au*OTg0ODQzNjQzLjE3Nzc4Mzg5ODE.*_ga*MTE5MTY0ODE4OC4xNzc3ODM4OTgx*_ga_26FEP9527K*czE3Nzk1MTkzNDYkbzMkZzAkdDE3Nzk1MTkzNDckajU5JGwwJGgw", 9.0, .anime, .onGoing),
        ("Dune: Part Two", "Movie · 2024-02-04", "https://image.tmdb.org/t/p/w600_and_h900_face/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg", 8.6, .movie, .planningTo),
        ("Breaking Bad", "TV · 2008-01-01", "https://media.themoviedb.org/t/p/w300_and_h450_face/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg", 9.5, .series, .watched),
    ]

    for (i, s) in samples.enumerated() {
        let item = Archive(
            compositeId: "preview-\(i)",
            title: s.0,
            subtitle: s.1,
            imageUrl: s.2,
            rating: s.3,
            mediaType: s.4,
            status: s.5
        )
        container.mainContext.insert(item)
    }

    return ArchiveView()
        .modelContainer(container)
}
