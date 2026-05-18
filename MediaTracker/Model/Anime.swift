import Foundation
import SwiftData
import SwiftUI

@Model
class Anime {
  @Attribute(.unique) var malId: Int
  var title: String
  var synopsis: String
  var imageUrl: String?
  var airingStart: String?
  var score: Double
  var type: String?

  init(
    malId: Int, title: String, synopsis: String, imageUrl: String?, airingStart: String?,
    score: Double, type: String?
  ) {
    self.malId = malId
    self.title = title
    self.synopsis = synopsis
    self.imageUrl = imageUrl
    self.airingStart = airingStart
    self.score = score / 2
    self.type = type
  }

  var shortAiringDate: String {
    return String(airingStart!.prefix(10))
  }
}
