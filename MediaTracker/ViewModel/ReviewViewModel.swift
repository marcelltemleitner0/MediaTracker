import Combine
import SwiftData
import SwiftUI

@MainActor
final class ReviewViewModel: ObservableObject {
  @Published var selectedRating: Double = 0
  @Published var reviewText: String = ""
  @Published var submitted: Bool = false
  var canSubmit: Bool {
    selectedRating > 0 && reviewText.count <= 1000
  }

  var buttonColor: Color {
    if submitted { return .green }
    if !canSubmit { return Color(.systemGray3) }
    return .red
  }

  func submitReview(
    title: String,
    subtitle: String,
    imageUrl: URL?,
    context: ModelContext,
    onDismiss: @escaping () -> Void
  ) {
    guard canSubmit else { return }

    let review = Review(
      mediaTitle: title,
      mediaSubtitle: subtitle,
      mediaImageUrl: imageUrl?.absoluteString,
      rating: selectedRating,
      reviewText: reviewText
    )
    context.insert(review)
    try? context.save()

    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
      submitted = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
      onDismiss()
    }
  }

  func reset() {
    selectedRating = 0
    reviewText = ""
    submitted = false
  }
}
