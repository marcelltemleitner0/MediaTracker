import Foundation
import SwiftData

@Model
final class Review {
    var id: UUID
    var mediaTitle: String
    var mediaSubtitle: String
    var mediaImageUrl: String?
    var rating: Double
    var reviewText: String
    var createdAt: Date
    
    init(
        mediaTitle: String,
        mediaSubtitle: String,
        mediaImageUrl: String? = nil,
        rating: Double,
        reviewText: String
    ) {
        self.id = UUID()
        self.mediaTitle = mediaTitle
        self.mediaSubtitle = mediaSubtitle
        self.mediaImageUrl = mediaImageUrl
        self.rating = rating
        self.reviewText = reviewText
        self.createdAt = Date()
    }
    var mediaKind: String {
        let prefix = mediaSubtitle.components(separatedBy: " ·").first ?? ""
        switch prefix.trimmingCharacters(in: .whitespaces) {
        case "Movie": return "Movie"
        case "TV": return "TV"
        case "Anime": return "Anime"
        case "Manga": return "Manga"
        case "Book": return "Book"
        default: return "Other"
        }
    }
    
    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: createdAt)
    }
}
