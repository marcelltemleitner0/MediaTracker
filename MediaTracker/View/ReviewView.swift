import SwiftData
import SwiftUI

struct ReviewView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \Review.createdAt, order: .reverse) private var allReviews: [Review]
  @State private var selectedCategory = "All"
  @State private var searchText = ""
  @State private var reviewToDelete: Review?

  let categories = ["All", "Movie", "TV", "Anime", "Manga", "Book"]

  var filtered: [Review] {
    allReviews.filter {
      (selectedCategory == "All" || $0.mediaKind == selectedCategory)
        && (searchText.isEmpty || $0.mediaTitle.localizedCaseInsensitiveContains(searchText)
          || $0.reviewText.localizedCaseInsensitiveContains(searchText))
    }
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 8) {
            ForEach(categories, id: \.self) { category in
              Button(category) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                  selectedCategory = category
                }
              }
              .font(.system(size: 14, weight: selectedCategory == category ? .semibold : .medium))
              .foregroundStyle(selectedCategory == category ? .white : Color(.label).opacity(0.7))
              .padding(.horizontal, 14).padding(.vertical, 7)
              .background(
                selectedCategory == category
                  ? AnyShapeStyle(Color.red.opacity(0.88)) : AnyShapeStyle(.ultraThinMaterial),
                in: Capsule()
              )
              .buttonStyle(.plain)
            }
          }
          .padding(.horizontal, 16).padding(.vertical, 10)
        }
        .background(.ultraThinMaterial)

        Divider()
        ScrollView {
          LazyVStack(spacing: 12) {
            ForEach(filtered) { review in
              ReviewCard(review: review) {
                  modelContext.delete(review)
              }
            }
          }
          .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Reviews")
        .navigationBarTitleDisplayMode(.large)
      }
    }
  }
    
  struct ReviewCard: View {
    let review: Review
    let onDelete: () -> Void
    @State private var isExpanded = false

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 12) {
          Group {
            if let url = review.resolvedImageURL {
              AsyncImage(url: url) { phase in
                if case .success(let img) = phase {
                  img.resizable().scaledToFill()
                } else {
                  PosterPlaceholder()
                }
              }
            } else {
              PosterPlaceholder()
            }
          }
          .frame(width: 52, height: 74)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)

          VStack(alignment: .leading, spacing: 4) {
            Text(review.mediaTitle).font(.system(size: 15, weight: .semibold)).lineLimit(2)
            Text(review.mediaSubtitle).font(.system(size: 12)).foregroundStyle(.secondary)
            HStack(spacing: 2) {
              ForEach(1...5, id: \.self) { i in
                let full = review.rating >= Double(i)
                let half = !full && review.rating >= Double(i) - 0.5
                Image(systemName: full ? "star.fill" : (half ? "star.leadinghalf.filled" : "star"))
                  .font(.system(size: 13))
                  .foregroundStyle(full || half ? .orange : Color(.quaternaryLabel))
              }
              Text(String(format: "%.1f", review.rating))
                .font(.system(size: 12, weight: .semibold)).foregroundStyle(.orange).padding(
                  .leading, 2)
            }
          }

          Spacer()
        }
        .padding(.horizontal, 14).padding(.top, 14)

        if !review.reviewText.isEmpty {
          Divider().padding(.horizontal, 14).padding(.top, 10)
          VStack(alignment: .leading, spacing: 6) {
            Text(review.reviewText)
              .font(.system(size: 14)).foregroundStyle(.primary.opacity(0.85))
              .lineLimit(isExpanded ? nil : 3)
              .animation(.easeInOut(duration: 0.2), value: isExpanded)
            if review.reviewText.count > 120 {
              Button(isExpanded ? "Show less" : "Read more") {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isExpanded.toggle() }
              }
              .font(.system(size: 13, weight: .medium)).foregroundStyle(.red)
            }
          }
          .padding(.horizontal, 14).padding(.top, 8)
        }

        HStack {
          Text(review.mediaKind)
            .font(.system(size: 11, weight: .semibold)).foregroundStyle(.red)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Color.red.opacity(0.10), in: Capsule())
          Spacer()
          Text(review.formattedDate).font(.system(size: 12)).foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 14)
      }
      .background(
        Color(.secondarySystemGroupedBackground),
        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
      .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
      .contextMenu {
        Button(role: .destructive) {
          onDelete()
        } label: {
          Label("Delete Review", systemImage: "trash")
        }
      }
    }
  }

  struct PosterPlaceholder: View {
    var body: some View {
      RoundedRectangle(cornerRadius: 8)
        .fill(Color(.tertiarySystemFill))
        .overlay(Image(systemName: "photo").foregroundStyle(.quaternary).font(.system(size: 18)))
    }
  }
}
