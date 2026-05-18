import SwiftData
import SwiftUI

struct ArchiveView: View {
  @Query private var items: [ArchiveItem]
  @Environment(\.modelContext) private var modelContext
  @State private var selectedStatus: WatchStatus? = nil

  private var filtered: [ArchiveItem] {
    items
      .filter { selectedStatus == nil || $0.status == selectedStatus }
      .sorted { $0.dateAdded > $1.dateAdded }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(WatchStatus.allCases, id: \.self) { status in
              FilterChip(
                label: status.rawValue, icon: status.icon, color: status.color,
                active: selectedStatus == status
              ) {
                withAnimation { selectedStatus = selectedStatus == status ? nil : status }
              }
            }
          }
          .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)
          
          ScrollView {
            LazyVStack(spacing: 10) {
              ForEach(filtered) { item in
                ArchiveRow(item: item)
                  .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                  )
                  .contextMenu {
                    ForEach(WatchStatus.allCases.filter { $0 != item.status }, id: \.self) { s in
                      Button {
                        item.status = s
                        try? modelContext.save()
                      } label: {
                        Label(s.rawValue, systemImage: s.icon)
                      }
                    }
                    Divider()
                    Button(role: .destructive) {
                      modelContext.delete(item)
                      try? modelContext.save()
                    } label: {
                      Label("Delete", systemImage: "trash")
                    }
                  }
              }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
          }
        }
      }
      .background(Color(.systemGroupedBackground))
      .navigationTitle("Library")
    }
  }

struct FilterChip: View {
  let label: String
  let icon: String
  let color: Color
  let active: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(label, systemImage: icon)
        .font(.system(size: 13, weight: active ? .semibold : .medium))
        .foregroundStyle(active ? .white : Color(.label).opacity(0.75))
        .padding(.horizontal, 12).padding(.vertical, 7)
        .background(Capsule().fill(active ? color : Color(.secondarySystemFill)))
    }
    .buttonStyle(.plain)
  }
}

struct ArchiveRow: View {
  let item: ArchiveItem

  var body: some View {
    HStack(spacing: 12) {
      AsyncImage(url: item.resolvedImageURL) { phase in
        if case .success(let img) = phase {
          img.resizable().scaledToFill()
        } else {
          Color(.secondarySystemFill)
        }
      }
      .frame(width: 46, height: 65).clipShape(RoundedRectangle(cornerRadius: 8))

      VStack(alignment: .leading, spacing: 4) {
        Text(item.title).font(.system(size: 15, weight: .semibold)).lineLimit(2)
        Text(item.subtitle).font(.system(size: 13)).foregroundStyle(.secondary).lineLimit(1)
        Label(String(format: "%.1f", item.rating), systemImage: "star.fill")
          .font(.system(size: 12, weight: .medium)).foregroundStyle(.orange)
      }
      Spacer()
      Image(systemName: item.status.icon).font(.system(size: 18)).foregroundStyle(item.status.color)
    }
    .padding(12)
  }
}
