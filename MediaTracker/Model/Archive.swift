import Foundation
import SwiftData
import SwiftUI

enum WatchStatus: String, Codable, CaseIterable {
    case watched    = "Watched"
    case onGoing    = "On Going"
    case planningTo = "Planning to Watch"
    
    var icon: String {
        switch self {
        case .watched:    return "checkmark.circle.fill"
        case .onGoing:    return "play.circle.fill"
        case .planningTo: return "bookmark.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .watched:    return .green
        case .onGoing:    return .blue
        case .planningTo: return .orange
        }
    }
}

enum MediaType: String, Codable, CaseIterable {
    case movie  = "Movie"
    case series = "TV"
    case anime  = "Anime"
    case manga  = "Manga"
    case book   = "Book"
}

@Model
class Archive {
    @Attribute(.unique) var compositeId: String
    var title: String
    var subtitle: String
    var imageUrl: String?
    var rating: Double
    var mediaTypeRaw: String
    var statusRaw: String
    var dateAdded: Date
    
    init(
        compositeId: String, title: String, subtitle: String,
        imageUrl: String?, rating: Double,
        mediaType: MediaType, status: WatchStatus
    ) {
        self.compositeId  = compositeId
        self.title        = title
        self.subtitle     = subtitle
        self.imageUrl     = imageUrl
        self.rating       = rating
        self.mediaTypeRaw = mediaType.rawValue
        self.statusRaw    = status.rawValue
        self.dateAdded    = Date()
    }
    
    var status: WatchStatus {
        get { WatchStatus(rawValue: statusRaw) ?? .planningTo }
        set { statusRaw = newValue.rawValue }
    }
    
    var mediaType: MediaType {
        MediaType(rawValue: mediaTypeRaw) ?? .movie
    }
    
    func toWidgetItem() -> WidgetMediaItem {
        WidgetMediaItem(
            id:           compositeId,
            title:        title,
            subtitle:     subtitle,
            imageUrl:     imageUrl,
            mediaTypeRaw: mediaTypeRaw,
            statusRaw:    statusRaw,
            rating:       rating
        )
    }
}
