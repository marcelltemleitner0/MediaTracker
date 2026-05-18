import SwiftData
import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @Environment(\.modelContext) private var modelContext

  private var hasNoContent: Bool {
    viewModel.movies.isEmpty && viewModel.series.isEmpty && viewModel.animeList.isEmpty
  }

  private var sections: [(title: String, icon: String, items: [MediaItem])] {
    [
      (
        "Movies", "film",
        viewModel.movies.prefix(10).map {
          MediaItem(
            title: $0.title, subtitle: $0.releaseDate, rating: $0.voteAverage,
            url: $0.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w342\($0)") })
        }
      ),
      (
        "TV Series", "tv",
        viewModel.series.prefix(10).map {
          MediaItem(
            title: $0.original_name, subtitle: $0.first_air_date, rating: $0.voteAverage,
            url: $0.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w342\($0)") })
        }
      ),
      (
        "Anime", "sparkles",
        viewModel.animeList.prefix(10).map {
          MediaItem(
            title: $0.title, subtitle: $0.shortAiringDate, rating: $0.score,
            url: $0.imageUrl.flatMap { URL(string: $0) })
        }
      ),
    ].filter { !$0.items.isEmpty }
  }

  var body: some View {
    NavigationStack {
      ZStack {
        Color(.systemGroupedBackground).ignoresSafeArea()

        if viewModel.isLoading && hasNoContent {
          VStack(spacing: 20) {
            ProgressView().scaleEffect(1.4).tint(.red)
            Text("Loading…").font(.system(size: 14)).foregroundStyle(.secondary)
          }
        } else if let error = viewModel.errorMessage {
          ContentUnavailableView(
            "Something went wrong", systemImage: "exclamationmark.triangle",
            description: Text(error))
        } else {
          ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
              if let featured = viewModel.movies.first {
                FeaturedCard(movie: featured)
              }

              ForEach(sections, id: \.title) { section in
                MediaSection(title: section.title, icon: section.icon, items: section.items)
              }

              Spacer(minLength: 24)
            }
            .padding(.top, 8)
          }
        }
      }
      .navigationTitle("Discover")
      .navigationBarTitleDisplayMode(.large)
      .task {
        await viewModel.fetchMoviesForHome(context: modelContext)
        await viewModel.fetchSeriesForHome(context: modelContext)
        await viewModel.fetchAnimeForHome(context: modelContext)
      }
    }
  }
}

private struct MediaItem {
  let title: String
  let subtitle: String
  let rating: Double
  let url: URL?
}

private struct FeaturedCard: View {
  let movie: Movie

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      AsyncImage(
        url: movie.posterPath.flatMap { URL(string: "https://image.tmdb.org/t/p/w780\($0)") }
      ) { phase in
        if case .success(let img) = phase {
          img.resizable().scaledToFill()
        } else {
          LinearGradient(
            colors: [.red.opacity(0.4), .indigo.opacity(0.6)], startPoint: .topLeading,
            endPoint: .bottomTrailing)
        }
      }
      .frame(maxWidth: .infinity).frame(height: 420).clipped()

      LinearGradient(
        colors: [.black.opacity(0), .black.opacity(0.3), .black.opacity(0.85)], startPoint: .top,
        endPoint: .bottom)

      VStack(alignment: .leading, spacing: 8) {
        Text("✦ FEATURED")
          .font(.system(size: 10, weight: .bold, design: .monospaced))
          .foregroundStyle(.white.opacity(0.7))
          .padding(.horizontal, 8).padding(.vertical, 3)
          .background(.ultraThinMaterial.opacity(0.6), in: Capsule())

        Text(movie.title)
          .font(.system(size: 26, weight: .bold))
          .foregroundStyle(.white)
          .lineLimit(2)

        HStack(spacing: 10) {
          Label(String(format: "%.1f", movie.voteAverage), systemImage: "star.fill")
            .font(.system(size: 13, weight: .semibold)).foregroundStyle(.orange)
          Text("·").foregroundStyle(.white.opacity(0.5))
          Text(String(movie.releaseDate.prefix(4)))
            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
          Text("·").foregroundStyle(.white.opacity(0.5))
          Label("Movie", systemImage: "film")
            .font(.system(size: 13)).foregroundStyle(.white.opacity(0.75))
        }
        .padding(.top, 4)
      }
      .padding(.horizontal, 20).padding(.bottom, 24)
    }
    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
  }
}

private struct MediaSection: View {
  let title: String
  let icon: String
  let items: [MediaItem]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(title, systemImage: icon)
        .font(.system(size: 18, weight: .bold))
        .padding(.horizontal, 20)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(alignment: .top, spacing: 14) {
          ForEach(items.indices, id: \.self) { i in
            PosterCard(item: items[i])
          }
        }
        .padding(.horizontal, 20).padding(.bottom, 4)
      }
    }
  }
}

private struct PosterCard: View {
  let item: MediaItem

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      AsyncImage(url: item.url) { phase in
        if case .success(let img) = phase {
          img.resizable().scaledToFill()
        } else {
          RoundedRectangle(cornerRadius: 12)
            .overlay(
              Image(systemName: "photo").font(.system(size: 24)).foregroundStyle(
                .white.opacity(0.4)))
        }
      }
      .frame(width: 130, height: 190)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

      Text(item.title)
        .font(.system(size: 13, weight: .semibold))
        .lineLimit(2)
        .frame(width: 130, alignment: .leading)

      HStack(spacing: 4) {
        Image(systemName: "star.fill").font(.system(size: 10)).foregroundStyle(.orange)
        Text(String(format: "%.1f", item.rating)).font(.system(size: 11, weight: .medium))
          .foregroundStyle(.orange)
        Text("·").foregroundStyle(.secondary).font(.system(size: 11))
        Text(item.subtitle).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
      }
      .frame(width: 130, alignment: .leading)
    }
    .contentShape(Rectangle())
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(
    for: Movie.self, Series.self, Anime.self, configurations: config)

  return HomeView()
    .modelContainer(container)
}
