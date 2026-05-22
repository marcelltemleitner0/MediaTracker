import Foundation
import SwiftData
import SwiftUI

class Book {
    @Attribute(.unique) var openLibraryId: String
    var title: String
    var authors: String
    var synopsis: String
    var imageUrl: String?
    var publishedDate: String?
    var rating: Double
    var pageCount: Int?
    
    init(
        openLibraryId: String, title: String, authors: String, synopsis: String,
        imageUrl: String?, publishedDate: String?, rating: Double, pageCount: Int?
    ) {
        self.openLibraryId = openLibraryId
        self.title = title
        self.authors = authors
        self.synopsis = synopsis
        self.imageUrl = imageUrl
        self.publishedDate = publishedDate
        self.rating = rating 
        self.pageCount = pageCount
    }
}
