import Combine
import Foundation
import SwiftData
import SwiftUI

class Movie {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var releaseDate: String
    var voteAverage: Double
    
    init(
        id: Int, title: String, overview: String, posterPath: String?, releaseDate: String,
        voteAverage: Double
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage / 2
    }
}
