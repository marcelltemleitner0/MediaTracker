import SwiftData
import SwiftUI

struct ArchiveView: View {
    @StateObject private var viewModel: ArchiveViewModel
    @State private var selectedTabId: String = "All"

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: ArchiveViewModel(modelContext: modelContext))
    }

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
        viewModel.items
            .filter { selectedStatus == nil || $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabBarPill(tabs: archiveTabs, selectedId: $selectedTabId)

                Divider()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { item in
                            ArchiveCard(item: item) {
                                viewModel.delete(item)
                            } onStatusChange: { newStatus in
                                viewModel.updateStatus(of: item, to: newStatus)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
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

