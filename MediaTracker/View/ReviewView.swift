import SwiftData
import SwiftUI

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Review.createdAt, order: .reverse) private var allReviews: [Review]
    @State private var selectedTabId: String = "All"
    @State private var searchText = ""
    
    private let viewModel = ReviewViewModel()
    
    private let reviewTabs: [TabItem] = [
        TabItem("All",   icon: "square.stack.fill", color: .red),
        TabItem("Movie", icon: "film",              color: .red),
        TabItem("TV",    icon: "tv",                color: .red),
        TabItem("Anime", icon: "sparkles",          color: .red),
        TabItem("Manga", icon: "book.closed",       color: .red),
        TabItem("Book",  icon: "books.vertical",    color: .red),
    ]
    
    var filtered: [Review] {
        allReviews.filter {
            (selectedTabId == "All" || $0.mediaKind == selectedTabId)
            && (searchText.isEmpty
                || $0.mediaTitle.localizedCaseInsensitiveContains(searchText)
                || $0.reviewText.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabBarPill(tabs: reviewTabs, selectedId: $selectedTabId)
                
                Divider()
                
                ScrollView {
                    if filtered.isEmpty {
                        ContentUnavailableView(
                            searchText.isEmpty ? "No Reviews Yet" : "No Results",
                            systemImage: searchText.isEmpty ? "square.and.pencil" : "magnifyingglass",
                            description: Text(
                                searchText.isEmpty
                                ? "Your reviews will appear here"
                                : "No reviews match \"\(searchText)\""
                            )
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { review in
                                ReviewCard(review: review) {
                                    viewModel.delete(review, context: modelContext)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Reviews")
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
                        if let urlString = review.mediaImageUrl,
                           let url = URL(string: urlString) {
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
                        Text(review.mediaTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .lineLimit(2)
                        Text(review.mediaSubtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        HStack(spacing: 2) {
                            ForEach(1...5, id: \.self) { i in
                                let full = review.rating >= Double(i)
                                let half = !full && review.rating >= Double(i) - 0.5
                                Image(systemName: full ? "star.fill" : (half ? "star.leadinghalf.filled" : "star"))
                                    .font(.system(size: 13))
                                    .foregroundStyle(full || half ? .orange : Color(.quaternaryLabel))
                            }
                            Text(String(format: "%.1f", review.rating))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.orange)
                                .padding(.leading, 2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                
                if !review.reviewText.isEmpty {
                    Divider()
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(review.reviewText)
                            .font(.system(size: 14))
                            .foregroundStyle(.primary.opacity(0.85))
                            .lineLimit(isExpanded ? nil : 3)
                            .animation(.easeInOut(duration: 0.2), value: isExpanded)
                        if review.reviewText.count > 120 {
                            Button(isExpanded ? "Show less" : "Read more") {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    isExpanded.toggle()
                                }
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.red)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                }
                
                HStack {
                    Text(review.mediaKind)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.red.opacity(0.10), in: Capsule())
                    Spacer()
                    Text(review.formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 14)
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
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Review.self, configurations: config)
    
    
    let samples = [
        (
            title: "Interstellar",
            subtitle: "Movie · 2014-11-06",
            url: "https://image.tmdb.org/t/p/original/yQvGrMoipbRoddT0ZR8tPoR7NfX.jpg",
            rating: 9.2,
            text: "Mind-bending visuals and incredible score."
        ),
        (
            title: "Attack on Titan",
            subtitle: "Anime · 2013-01-01",
            url: "https://cdn.myanimelist.net/images/anime/1907/134102l.jpg?_gl=1*yiysm6*_gcl_au*OTg0ODQzNjQzLjE3Nzc4Mzg5ODE.*_ga*MTE5MTY0ODE4OC4xNzc3ODM4OTgx*_ga_26FEP9527K*czE3Nzk1MTkzNDYkbzMkZzAkdDE3Nzk1MTkzNDckajU5JGwwJGgw",
            rating: 9.0,
            text: "Phenomenal storytelling and high stakes action."
        ),
        (
            title: "Dune: Part Two",
            subtitle: "Movie · 2024-02-04",
            url: "https://image.tmdb.org/t/p/w600_and_h900_face/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg",
            rating: 8.6,
            text: "Visually stunning and faithful to the source material."
        ),
        (
            title: "Breaking Bad",
            subtitle: "TV · 2008-01-01",
            url: "https://media.themoviedb.org/t/p/w300_and_h450_face/ztkUQFLlC19CCMYHW9o1zWhJRNq.jpg",
            rating: 9.5,
            text: "Masterclass in character development and pacing."
        )
    ]
    
    for sample in samples {
        let review = Review(
            mediaTitle: sample.title,
            mediaSubtitle: sample.subtitle,
            mediaImageUrl: sample.url,
            rating: sample.rating,
            reviewText: sample.text
        )
        container.mainContext.insert(review)
    }
    
    return ReviewView()
        .modelContainer(container)
}
