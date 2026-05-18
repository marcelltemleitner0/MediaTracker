import Combine
import Foundation
import SwiftData
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
  @Published var movies: [Movie] = []
  @Published var series: [Series] = []
  @Published var animeList: [Anime] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let apiKey = Config.TMDBAPIKEY

  private struct TMDBResponse: Decodable { let results: [TMDBMovie] }
  private struct TMDBTvResponse: Decodable { let results: [TMDBSeries] }

  private struct TMDBMovie: Decodable {
    let id: Int
    let title: String
    let overview: String
    let poster_path: String?
    let release_date: String
    let vote_average: Double
  }

  private struct TMDBSeries: Decodable {
    let id: Int
    let original_name: String
    let overview: String
    let poster_path: String?
    let first_air_date: String
    let vote_average: Double
  }

  private struct JikanResponse: Decodable {
    let data: [JikanAnime]
  }

  private struct JikanAnime: Decodable {
    let mal_id: Int
    let title: String
    let synopsis: String?
    let score: Double?
    let type: String?
    let images: JikanImages
    let aired: JikanAired
  }

  private struct JikanImages: Decodable {
    let jpg: JikanImageSource
  }

  private struct JikanImageSource: Decodable {
    let large_image_url: String?
  }

  private struct JikanAired: Decodable {
    let from: String?
  }

  func fetchMoviesForHome(context: ModelContext) async {
    isLoading = true
    errorMessage = nil
    guard
      let url = URL(
        string:
          "https://api.themoviedb.org/3/discover/movie?api_key=\(apiKey)&sort_by=primary_release_date.desc&primary_release_date.lte=2026-05-04&vote_count.gte=100"
      )
    else { return }
    let request = URLRequest(url: url)

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let decoded = try JSONDecoder().decode(TMDBResponse.self, from: data)
      for tmdbMovie in decoded.results {
        let movie = Movie(
          id: tmdbMovie.id, title: tmdbMovie.title, overview: tmdbMovie.overview,
          posterPath: tmdbMovie.poster_path, releaseDate: tmdbMovie.release_date,
          voteAverage: tmdbMovie.vote_average)
        context.insert(movie)
      }
      try context.save()
      movies = decoded.results.map {
        Movie(
          id: $0.id, title: $0.title, overview: $0.overview, posterPath: $0.poster_path,
          releaseDate: $0.release_date, voteAverage: $0.vote_average)
      }
    } catch { errorMessage = error.localizedDescription }
    isLoading = false
  }

  func fetchSeriesForHome(context: ModelContext) async {
    isLoading = true
    errorMessage = nil
    guard
      let url = URL(
        string:
          "https://api.themoviedb.org/3/discover/tv?api_key=\(apiKey)&sort_by=primary_release_date.desc&primary_release_date.lte=2026-05-04&vote_count.gte=100"
      )
    else { return }
    let request = URLRequest(url: url)

    do {
      let (data, _) = try await URLSession.shared.data(for: request)
      let decoded = try JSONDecoder().decode(TMDBTvResponse.self, from: data)
      for tmdbSeries in decoded.results {
        let seriesItem = Series(
          id: tmdbSeries.id, original_name: tmdbSeries.original_name, overview: tmdbSeries.overview,
          posterPath: tmdbSeries.poster_path, first_air_date: tmdbSeries.first_air_date,
          voteAverage: tmdbSeries.vote_average)
        context.insert(seriesItem)
      }
      try context.save()
      series = decoded.results.map {
        Series(
          id: $0.id, original_name: $0.original_name, overview: $0.overview,
          posterPath: $0.poster_path, first_air_date: $0.first_air_date,
          voteAverage: $0.vote_average)
      }
    } catch { errorMessage = error.localizedDescription }
    isLoading = false
  }

  func fetchAnimeForHome(context: ModelContext) async {
    isLoading = true
    errorMessage = nil

    guard let url = URL(string: "https://api.jikan.moe/v4/seasons/now?limit=10") else { return }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let decoded = try JSONDecoder().decode(JikanResponse.self, from: data)
      var seenIds = Set<Int>()
      let uniqueItems = decoded.data.filter { seenIds.insert($0.mal_id).inserted }

      for item in uniqueItems {
        let anime = Anime(
          malId: item.mal_id,
          title: item.title,
          synopsis: item.synopsis ?? "No description.",
          imageUrl: item.images.jpg.large_image_url,
          airingStart: item.aired.from,
          score: item.score ?? 0.0,
          type: item.type
        )
        context.insert(anime)
      }

      try context.save()

      animeList = uniqueItems.map { item in
        Anime(
          malId: item.mal_id,
          title: item.title,
          synopsis: item.synopsis ?? "",
          imageUrl: item.images.jpg.large_image_url,
          airingStart: item.aired.from,
          score: item.score ?? 0.0,
          type: item.type
        )
      }
    } catch {
      errorMessage = error.localizedDescription
    }

    isLoading = false
  }
}
