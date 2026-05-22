import SwiftUI

struct JikanAnimeResponse: Decodable { let data: [JikanAnime] }
struct JikanMangaResponse: Decodable { let data: [JikanManga] }

struct JikanAnime: Decodable {
    let mal_id: Int
    let title: String
    let synopsis: String?
    let score: Double?
    let type: String?
    let images: JikanImages
    let aired: JikanAired
}

struct JikanManga: Decodable {
    let mal_id: Int
    let title: String
    let synopsis: String?
    let score: Double?
    let type: String?
    let images: JikanImages
    let published: JikanPublished
}

struct JikanImages: Decodable { let jpg: JikanImageSource }
struct JikanImageSource: Decodable { let large_image_url: String? }
struct JikanAired: Decodable { let from: String? }
struct JikanPublished: Decodable { let from: String? }

 struct OpenLibrarySearchResponse: Decodable {
    let docs: [OpenLibraryDoc]
}

 struct OpenLibraryDoc: Decodable {
    let key: String
    let title: String?
    let author_name: [String]?
    let cover_i: Int?
    let first_publish_year: Int?
    let number_of_pages_median: Int?
    let ratings_average: Double?
}
