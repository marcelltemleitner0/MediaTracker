import SwiftData
import SwiftUI

@MainActor
final class ReviewViewModel {
    func canSubmit(rating: Double, reviewText: String) -> Bool {
        rating > 0 && reviewText.count <= 1000
    }
    
    func add(
        rating: Double,
        reviewText: String,
        title: String,
        subtitle: String,
        imageUrl: URL?,
        context: ModelContext,
        onDismiss: @escaping () -> Void
    ) {
        guard canSubmit(rating: rating, reviewText: reviewText) else { return }
        let review = Review(
            mediaTitle: title,
            mediaSubtitle: subtitle,
            mediaImageUrl: imageUrl?.absoluteString,
            rating: rating,
            reviewText: reviewText
        )
        context.insert(review)
        try? context.save()
        onDismiss()
    }
    
    func delete(_ review: Review, context: ModelContext) {
        context.delete(review)
        try? context.save()
    }
}
