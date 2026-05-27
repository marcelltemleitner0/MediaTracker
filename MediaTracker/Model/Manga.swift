import Foundation
import SwiftData
import SwiftUI

class Manga {
    @Attribute(.unique) var malId: Int
    var title: String
    var synopsis: String
    var imageUrl: String?
    var publishedStart: String?
    var score: Double
    var type: String?
    
    init(
        malId: Int, title: String, synopsis: String, imageUrl: String?,
        publishedStart: String?, score: Double, type: String?
    ) {
        self.malId = malId
        self.title = title
        self.synopsis = synopsis
        self.imageUrl = imageUrl
        self.publishedStart = publishedStart
        self.score = score / 2
        self.type = type
    }
    
}
