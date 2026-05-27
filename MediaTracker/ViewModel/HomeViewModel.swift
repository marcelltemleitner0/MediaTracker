import Combine
import Foundation
import SwiftUI
import TMDb

@Observable
class HomeViewModel {
    var movies: [Movie] = []
    var series: [Series] = []
    var animeList: [Anime] = []
    var isLoading = false
    var errorMessage: String?
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    func fetchMoviesForHome() async {
        isLoading = true
        errorMessage = nil
        do {
            let page = try await TMDbClient.shared.discover.movies()
            movies = page.results.map { map(tmdbMovie: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchSeriesForHome() async {
        isLoading = true
        errorMessage = nil
        do {
            let page = try await TMDbClient.shared.discover.tvSeries()
            series = page.results.map { map(tmdbSeries: $0) }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func fetchAnimeForHome() async {
        isLoading = true
        errorMessage = nil
        guard let url = URL(string: "https://api.jikan.moe/v4/seasons/now?limit=10") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(JikanAnimeResponse.self, from: data)
            var seenIds = Set<Int>()
            animeList = decoded.data
                .filter { seenIds.insert($0.mal_id).inserted }
                .map { item in
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
    
    private func map(tmdbMovie: TMDb.MovieListItem) -> Movie {
        Movie(
            id: tmdbMovie.id,
            title: tmdbMovie.title,
            overview: tmdbMovie.overview,
            posterPath: tmdbMovie.posterPath?.path,
            releaseDate: tmdbMovie.releaseDate.map { dateFormatter.string(from: $0) } ?? "",
            voteAverage: tmdbMovie.voteAverage ?? 0.0
        )
    }
    
    private func map(tmdbSeries: TMDb.TVSeriesListItem) -> Series {
        Series(
            id: tmdbSeries.id,
            original_name: tmdbSeries.name,
            overview: tmdbSeries.overview,
            posterPath: tmdbSeries.posterPath?.path,
            first_air_date: tmdbSeries.firstAirDate.map { dateFormatter.string(from: $0) } ?? "",
            voteAverage: tmdbSeries.voteAverage ?? 0.0
        )
    }
}
