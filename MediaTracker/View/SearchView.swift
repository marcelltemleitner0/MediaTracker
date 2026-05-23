import SwiftData
import SwiftUI

struct SearchResult: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let posterPath: String?
    let imageUrl: String?
    let rating: Double
}

struct SearchCategory {
    let tab: TabItem
    let results: (SearchViewModel) -> [SearchResult]
}

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State var archiveViewModel: ArchiveViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTabId: String = "Top Results"
    @Environment(\.isSearching) private var isSearching

    private var categories: [SearchCategory] {
        [
            SearchCategory(tab: TabItem("Movies", icon: "film", color: .red)) { vm in
                vm.movieResults.map {
                    SearchResult(
                        id: "movie-\($0.id)",
                        title: $0.title,
                        subtitle: "Movie · \($0.releaseDate)",
                        posterPath: $0.posterPath,
                        imageUrl: nil,
                        rating: $0.voteAverage
                    )
                }
            },
            SearchCategory(tab: TabItem("Tv Series", icon: "tv", color: .red)) { vm in
                vm.seriesResults.map {
                    SearchResult(
                        id: "tv-\($0.id)",
                        title: $0.original_name,
                        subtitle: "TV · \($0.first_air_date)",
                        posterPath: $0.posterPath,
                        imageUrl: nil,
                        rating: $0.voteAverage
                    )
                }
            },
            SearchCategory(tab: TabItem("Animes", icon: "sparkles", color: .red)) { vm in
                vm.animeResults.map {
                    SearchResult(
                        id: "anime-\($0.malId)",
                        title: $0.title,
                        subtitle: "Anime · \($0.type ?? "")",
                        posterPath: nil,
                        imageUrl: $0.imageUrl,
                        rating: $0.score
                    )
                }
            },
            SearchCategory(tab: TabItem("Manga", icon: "book.closed", color: .red)) { vm in
                vm.mangaResults.map {
                    SearchResult(
                        id: "manga-\($0.malId)",
                        title: $0.title,
                        subtitle: "Manga · \($0.type ?? "")",
                        posterPath: nil,
                        imageUrl: $0.imageUrl,
                        rating: $0.score
                    )
                }
            },
            SearchCategory(tab: TabItem("Books", icon: "books.vertical", color: .red)) { vm in
                vm.bookResults.map {
                    SearchResult(
                        id: "book-\($0.openLibraryId)",
                        title: $0.title,
                        subtitle: "Book · \($0.authors)",
                        posterPath: nil,
                        imageUrl: $0.imageUrl,
                        rating: $0.rating
                    )
                }
            },
        ]
    }

    private var topResults: [SearchResult] {
        categories
            .flatMap { $0.results(viewModel).prefix(3) }
            .sorted { $0.rating > $1.rating }
    }

    private var searchTabs: [TabItem] {
        [TabItem("Top Results", icon: "star.fill", color: .red)]
        + categories.map(\.tab)
    }

    private func results(for tabId: String) -> [SearchResult] {
        if tabId == "Top Results" { return topResults }
        return categories.first { $0.tab.id == tabId }?.results(viewModel) ?? []
    }

    var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                TabBarPill(tabs: searchTabs, selectedId: $selectedTabId)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if results(for: selectedTabId).isEmpty {
                    ContentUnavailableView(
                        "No results",
                        systemImage: "magnifyingglass",
                        description: Text("No results found for this category")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(results(for: selectedTabId)) { result in
                                SearchRow(result: result, archiveViewModel: archiveViewModel)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
            } else {
                ContentUnavailableView(
                    "Search",
                    systemImage: "magnifyingglass",
                    description: Text("Search for movies, TV series, anime, manga, and books")
                )
            }
        }
    }
}

struct SearchRow: View {
    let result: SearchResult
    let archiveViewModel: ArchiveViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var showReviewSheet = false

    private var resolvedImageUrl: URL? {
        if let path = result.posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w92\(path)")
        } else if let url = result.imageUrl {
            return URL(string: url.replacingOccurrences(of: "http://", with: "https://"))
        }
        return nil
    }

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let url = resolvedImageUrl {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Color(.secondarySystemFill)
                        }
                    }
                } else {
                    Color(.secondarySystemFill)
                }
            }
            .frame(width: 52, height: 74)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(2)
                Text(result.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Label(String(format: "%.1f", result.rating), systemImage: "star.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.orange)
            }

            Spacer()

            Menu {
                Menu {
                    Button { archive(status: .watched) } label: {
                        Label("Watched", systemImage: "checkmark.circle.fill")
                    }
                    Button { archive(status: .onGoing) } label: {
                        Label("On Going", systemImage: "play.circle.fill")
                    }
                    Button { archive(status: .planningTo) } label: {
                        Label("Planning to Watch", systemImage: "bookmark.fill")
                    }
                } label: {
                    Label("Mark as…", systemImage: "tag")
                }

                Divider()
                Button { showReviewSheet = true } label: {
                    Label("Leave a Review", systemImage: "square.and.pencil")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .sheet(isPresented: $showReviewSheet) {
            ReviewSheet(title: result.title, subtitle: result.subtitle, imageUrl: resolvedImageUrl)
        }

        Divider().padding(.leading, 80)
    }

    private func archive(status: WatchStatus) {
        archiveViewModel.addOrUpdate(result, status: status, context: modelContext)
    }
}

#Preview {
    @Previewable @State var searchText = ""
    let searchVM = SearchViewModel()
    let archiveVM = ArchiveViewModel()

    NavigationStack {
        SearchView(viewModel: searchVM, archiveViewModel: archiveVM)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
    }
    .searchable(text: $searchText, placement: .toolbar, prompt: Text("Movies, series, anime…"))
    .onChange(of: searchText) { _, newValue in
        searchVM.search(query: newValue)
    }
    .onSubmit(of: .search) {
        searchVM.search(query: searchText)
    }
    .modelContainer(for: [Review.self, Archive.self], inMemory: true)
}
