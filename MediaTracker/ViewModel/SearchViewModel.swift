import Combine
import Foundation
import SwiftUI
import TMDb

@Observable
class SearchViewModel {
    var movieResults: [Movie] = []
    var seriesResults: [Series] = []
    var animeResults: [Anime] = []
    var mangaResults: [Manga] = []
    var bookResults: [Book] = []
    var isLoading = false
    var errorMessage: String?
    
    private var searchTask: Task<Void, Never>?
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
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
        async let books = searchBooks(query: query)
        let (m, s, a, mg, b) = await (movies, series, anime, manga,books)
        movieResults = m
        seriesResults = s
        animeResults = a
        mangaResults = mg
        bookResults = b
        isLoading = false
    }
    
    func clearResults() {
        movieResults = []
        seriesResults = []
        animeResults = []
        mangaResults = []
        bookResults = []
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
            let decoded = try JSONDecoder().decode(JikanAnimeResponse.self, from: data)
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
    
    private func searchBooks(query: String) async -> [Book] {
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        guard let url = URL(string: "https://openlibrary.org/search.json?q=\(encoded)&limit=10&fields=key,title,author_name,cover_i,first_publish_year,number_of_pages_median,ratings_average") else {
            return []
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
            var seenIds = Set<String>()
            return decoded.docs
                .filter { seenIds.insert($0.key).inserted }
                .compactMap { doc -> Book? in
                    guard let title = doc.title else { return nil }
                    let coverUrl: String? = doc.cover_i.map {
                        "https://covers.openlibrary.org/b/id/\($0)-M.jpg"
                    }
                    return Book(
                        openLibraryId: doc.key,
                        title: title,
                        authors: doc.author_name?.joined(separator: ", ") ?? "Unknown",
                        synopsis: "No description.",
                        imageUrl: coverUrl,
                        publishedDate: doc.first_publish_year.map { String($0) },
                        rating: doc.ratings_average ?? 0.0,
                        pageCount: doc.number_of_pages_median
                    )
                }
        } catch { return [] }
    }
    
    
    
    
    
    
    
    
}
