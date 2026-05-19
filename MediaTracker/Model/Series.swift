import Combine
import Foundation
import SwiftData
import SwiftUI

class Series {
  @Attribute(.unique) var id: Int
  var original_name: String
  var overview: String
  var posterPath: String?
  var first_air_date: String
  var voteAverage: Double

  init(
    id: Int, original_name: String, overview: String, posterPath: String?, first_air_date: String,
    voteAverage: Double
  ) {
    self.id = id
    self.original_name = original_name
    self.overview = overview
    self.posterPath = posterPath
    self.first_air_date = first_air_date
    self.voteAverage = voteAverage / 2
  }
}
