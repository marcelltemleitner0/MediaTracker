import Combine
import Foundation
import SwiftUI
import TMDb

@MainActor
class SearchViewModel: ObservableObject {
    @Published var movieResults: [Movie] = []
    @Published var seriesResults: [Series] = []
    @Published var animeResults: [Anime] = []
    @Published var mangaResults: [Manga] = []
    @Published var bookResults: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    private struct JikanSearchResponse: Decodable { let data: [JikanAnime] }
    private struct JikanMangaResponse: Decodable { let data: [JikanManga] }
    
    private struct JikanAnime: Decodable {
        let mal_id: Int
        let title: String
        let synopsis: String?
        let score: Double?
        let type: String?
        let images: JikanImages
        let aired: JikanAired
    }
    
    private struct JikanManga: Decodable {
        let mal_id: Int
        let title: String
        let synopsis: String?
        let score: Double?
        let type: String?
        let images: JikanImages
        let published: JikanPublished
    }
    
    private struct JikanImages: Decodable { let jpg: JikanImageSource }
    private struct JikanImageSource: Decodable { let large_image_url: String? }
    private struct JikanAired: Decodable { let from: String? }
    private struct JikanPublished: Decodable { let from: String? }
    
    func search(query: String) {
        searchTask?.cancel()
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            clearResults()
            return
        }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled else { return }
            await performSearch(query: query)
        }
    }
    
    private func performSearch(query: String) async {
        isLoading = true
        errorMessage = nil
        async let movies = searchMovies(query: query)
        async let series = searchSeries(query: query)
        async let anime = searchAnime(query: query)
        async let manga = searchManga(query: query)
        let (m, s, a, mg) = await (movies, series, anime, manga)
        movieResults = m
        seriesResults = s
        animeResults = a
        mangaResults = mg
        isLoading = false
    }
    
    func clearResults() {
        movieResults = []
        seriesResults = []
        animeResults = []
        mangaResults = []
        errorMessage = nil
    }
    
    private func searchMovies(query: String) async -> [Movie] {
        do {
            let page = try await TMDbClient.shared.search.searchMovies(query: query)
            return page.results.map {
                Movie(
                    id: $0.id,
                    title: $0.title,
                    overview: $0.overview,
                    posterPath: $0.posterPath?.path,
                    releaseDate: $0.releaseDate.map { dateFormatter.string(from: $0) } ?? "",
                    voteAverage: $0.voteAverage ?? 0.0
                )
            }
        } catch { return [] }
    }
    
    private func searchSeries(query: String) async -> [Series] {
        do {
            let page = try await TMDbClient.shared.search.searchTVSeries(query: query)
            return page.results.map {
                Series(
                    id: $0.id,
                    original_name: $0.name,
                    overview: $0.overview,
                    posterPath: $0.posterPath?.path,
                    first_air_date: $0.firstAirDate.map { dateFormatter.string(from: $0) } ?? "",
                    voteAverage: $0.voteAverage ?? 0.0
                )
            }
        } catch { return [] }
    }
    
    private func searchAnime(query: String) async -> [Anime] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://api.jikan.moe/v4/anime?q=\(encoded)&limit=10") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(JikanSearchResponse.self, from: data)
            var seenIds = Set<Int>()
            return decoded.data
                .filter { seenIds.insert($0.mal_id).inserted }
                .map {
                    Anime(
                        malId: $0.mal_id, title: $0.title,
                        synopsis: $0.synopsis ?? "No description.",
                        imageUrl: $0.images.jpg.large_image_url,
                        airingStart: $0.aired.from,
                        score: $0.score ?? 0.0, type: $0.type)
                }
        } catch { return [] }
    }
    
    private func searchManga(query: String) async -> [Manga] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://api.jikan.moe/v4/manga?q=\(encoded)&limit=10") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(JikanMangaResponse.self, from: data)
            var seenIds = Set<Int>()
            return decoded.data
                .filter { seenIds.insert($0.mal_id).inserted }
                .map {
                    Manga(
                        malId: $0.mal_id, title: $0.title,
                        synopsis: $0.synopsis ?? "No description.",
                        imageUrl: $0.images.jpg.large_image_url,
                        publishedStart: $0.published.from,
                        score: $0.score ?? 0.0, type: $0.type)
                }
        } catch { return [] }
    }
}
