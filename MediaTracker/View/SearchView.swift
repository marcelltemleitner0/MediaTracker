import SwiftData
import SwiftUI

struct SearchView: View {
  @ObservedObject var viewModel: SearchViewModel
  @State private var selectedTab = "Top Results"
  @Environment(\.isSearching) private var isSearching

  let tabs = ["Top Results", "Movies", "Tv Series", "Animes", "Manga", "Books"]

  var body: some View {
    VStack(spacing: 0) {
      if isSearching {
        LiquidGlassTabBar(tabs: tabs, selectedTab: $selectedTab)

        if viewModel.isLoading {
          Spacer()
          ProgressView()
          Spacer()
        } else {
          ScrollView {
            LazyVStack(spacing: 0) {
              switch selectedTab {
              case "Movies":
                ForEach(viewModel.movieResults, id: \.id) { movie in
                  SearchRow(
                    title: movie.title,
                    subtitle: "Movie · \(movie.releaseDate)",
                    posterPath: movie.posterPath,
                    rating: movie.voteAverage)
                }

              case "Tv Series":
                ForEach(viewModel.seriesResults, id: \.id) { series in
                  SearchRow(
                    title: series.original_name,
                    subtitle: "TV · \(series.first_air_date)",
                    posterPath: series.posterPath,
                    rating: series.voteAverage)
                }

              case "Animes":
                ForEach(viewModel.animeResults, id: \.malId) { anime in
                  SearchRow(
                    title: anime.title,
                    subtitle: "Anime · \(anime.type ?? "")",
                    posterPath: nil,
                    imageUrl: anime.imageUrl,
                    rating: anime.score)
                }

              case "Manga":
                ForEach(viewModel.mangaResults, id: \.malId) { manga in
                  SearchRow(
                    title: manga.title,
                    subtitle: "Manga · \(manga.type ?? "")",
                    posterPath: nil,
                    imageUrl: manga.imageUrl,
                    rating: manga.score)
                }

              case "Books":
                ForEach(viewModel.bookResults, id: \.googleId) { book in
                  SearchRow(
                    title: book.title,
                    subtitle: "Book · \(book.authors)",
                    posterPath: nil,
                    imageUrl: book.imageUrl,
                    rating: book.rating)
                }

              default:
                ForEach(viewModel.movieResults.prefix(3), id: \.id) { movie in
                  SearchRow(
                    title: movie.title,
                    subtitle: "Movie · \(movie.releaseDate)",
                    posterPath: movie.posterPath,
                    rating: movie.voteAverage)
                }
                ForEach(viewModel.seriesResults.prefix(3), id: \.id) { series in
                  SearchRow(
                    title: series.original_name,
                    subtitle: "TV · \(series.first_air_date)",
                    posterPath: series.posterPath,
                    rating: series.voteAverage)
                }
                ForEach(viewModel.animeResults.prefix(3), id: \.malId) { anime in
                  SearchRow(
                    title: anime.title,
                    subtitle: "Anime · \(anime.type ?? "")",
                    posterPath: nil,
                    imageUrl: anime.imageUrl,
                    rating: anime.score)
                }
                ForEach(viewModel.mangaResults.prefix(3), id: \.malId) { manga in
                  SearchRow(
                    title: manga.title,
                    subtitle: "Manga · \(manga.type ?? "")",
                    posterPath: nil,
                    imageUrl: manga.imageUrl,
                    rating: manga.score)
                }
                ForEach(viewModel.bookResults.prefix(3), id: \.googleId) { book in
                  SearchRow(
                    title: book.title,
                    subtitle: "Book · \(book.authors)",
                    posterPath: nil,
                    imageUrl: book.imageUrl,
                    rating: book.rating)
                }
              }
            }
            .padding(.top, 8)
          }
        }
      } else {
        ContentUnavailableView(
          "Search",
          systemImage: "magnifyingglass",
          description: Text("Search for movies, TV series, anime, manga, and books"))
      }
    }
  }
}

// MARK: - Tab Bar

struct LiquidGlassTabBar: View {
  let tabs: [String]
  @Binding var selectedTab: String
  @Namespace private var tabAnimation

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(tabs, id: \.self) { tab in
          TabPill(title: tab, isSelected: selectedTab == tab, namespace: tabAnimation)
            .onTapGesture {
              withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
              }
            }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
    .background(.ultraThinMaterial)
  }
}

struct TabPill: View {
  let title: String
  let isSelected: Bool
  var namespace: Namespace.ID

  var body: some View {
    ZStack {
      if isSelected {
        Capsule()
          .fill(Color.red.opacity(0.85))
          .overlay {
            Capsule()
              .fill(
                LinearGradient(
                  colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                  startPoint: .topLeading, endPoint: .bottomTrailing))
          }
          .overlay {
            Capsule()
              .strokeBorder(
                LinearGradient(
                  colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                  startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 0.75)
          }
          .shadow(color: Color.red.opacity(0.4), radius: 8, x: 0, y: 4)
          .matchedGeometryEffect(id: "selectedPill", in: namespace)
      } else {
        Capsule()
          .fill(.ultraThinMaterial)
          .overlay {
            Capsule()
              .fill(
                LinearGradient(
                  colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                  startPoint: .topLeading, endPoint: .bottomTrailing))
          }
          .overlay {
            Capsule()
              .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
          }
      }

      Text(title)
        .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
        .foregroundStyle(isSelected ? .white : Color(.label).opacity(0.75))
        .padding(.horizontal, 16)
        .padding(.vertical, 9)
    }
    .fixedSize()
    .contentShape(Capsule())
  }
}
struct SearchRow: View {
  let title: String
  let subtitle: String
  var posterPath: String?
  var imageUrl: String? = nil
  let rating: Double

  @State private var showReviewSheet = false
  @Environment(\.modelContext) private var modelContext

  private var resolvedImageUrl: URL? {
    if let path = posterPath {
      return URL(string: "https://image.tmdb.org/t/p/w92\(path)")
    } else if let url = imageUrl {
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
        Text(title)
          .font(.system(size: 15, weight: .semibold))
          .lineLimit(2)
        Text(subtitle)
          .font(.system(size: 13))
          .foregroundStyle(.secondary)
          .lineLimit(1)
        Label(String(format: "%.1f", rating), systemImage: "star.fill")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(.orange)
      }

      Spacer()

      Menu {
        Menu {
          Button {
            archive(status: .watched)
          } label: {
            Label("Watched", systemImage: "checkmark.circle.fill")
          }
          Button {
            archive(status: .onGoing)
          } label: {
            Label("On Going", systemImage: "play.circle.fill")
          }
          Button {
            archive(status: .planningTo)
          } label: {
            Label("Planning to Watch", systemImage: "bookmark.fill")
          }
        } label: {
          Label("Mark as…", systemImage: "tag")
        }

        Divider()

        Button {
        } label: {
          Label("Add to Playlist", systemImage: "plus.circle")
        }

        Button {
          showReviewSheet = true
        } label: {
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
      ReviewSheet(title: title, subtitle: subtitle, imageUrl: resolvedImageUrl)
    }

    Divider().padding(.leading, 80)
  }
  private func archive(status: WatchStatus) {
    let mediaPrefix = subtitle.components(separatedBy: " ·").first ?? "item"
    let compositeId =
      "\(mediaPrefix.lowercased())-\(title.lowercased().filter { !$0.isWhitespace })"

    let descriptor = FetchDescriptor<ArchiveItem>(
      predicate: #Predicate { $0.compositeId == compositeId }
    )
    if let existing = try? modelContext.fetch(descriptor).first {
      existing.status = status
    } else {
      let item = ArchiveItem(
        compositeId: compositeId,
        title: title,
        subtitle: subtitle,
        imageUrl: resolvedImageUrl?.absoluteString,
        rating: rating,
        mediaType: MediaType(rawValue: mediaPrefix) ?? .movie,
        status: status
      )
      modelContext.insert(item)
    }
    try? modelContext.save()
  }
}
