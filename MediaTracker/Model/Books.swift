import Foundation
import SwiftData
import SwiftUI

class Book {
  @Attribute(.unique) var googleId: String
  var title: String
  var authors: String
  var synopsis: String
  var imageUrl: String?
  var publishedDate: String?
  var rating: Double
  var pageCount: Int?

  init(
    googleId: String, title: String, authors: String, synopsis: String,
    imageUrl: String?, publishedDate: String?, rating: Double, pageCount: Int?
  ) {
    self.googleId = googleId
    self.title = title
    self.authors = authors
    self.synopsis = synopsis
    self.imageUrl = imageUrl
    self.publishedDate = publishedDate
    self.rating = rating / 2
    self.pageCount = pageCount
  }
}
