import SwiftData
import SwiftUI

struct ReviewSheet: View {
    let title: String
    let subtitle: String
    let imageUrl: URL?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedRating: Double = 0
    @State private var reviewText: String = ""
    @State private var submitted = false

    private let viewModel = ReviewViewModel()

    private var buttonColor: Color {
        if submitted { return .green }
        if !viewModel.canSubmit(rating: selectedRating, reviewText: reviewText) { return Color(.systemGray3) }
        return .red
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    HStack(spacing: 14) {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                Color(.secondarySystemFill)
                            }
                        }
                        .frame(width: 56, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.system(size: 17, weight: .semibold))
                                .lineLimit(2)
                            Text(subtitle)
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Divider()

                    VStack(spacing: 10) {
                        Text("Your Rating")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.5)

                        StarRatingView(rating: $selectedRating)

                        Text(selectedRating > 0 ? String(format: "%.0f / 5", selectedRating) : "Tap to rate")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(selectedRating > 0 ? .orange : .secondary)
                            .animation(.easeInOut(duration: 0.15), value: selectedRating)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Write a Review")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .kerning(0.5)
                            .padding(.horizontal, 20)

                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
                                )

                            if reviewText.isEmpty {
                                Text("Share your thoughts about \(title)…")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(.tertiaryLabel))
                                    .padding(.horizontal, 14)
                                    .padding(.top, 13)
                            }

                            TextEditor(text: $reviewText)
                                .font(.system(size: 15))
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(minHeight: 130)
                        }
                        .padding(.horizontal, 20)

                        HStack {
                            Spacer()
                            Text("\(reviewText.count) / 1000")
                                .font(.system(size: 12))
                                .foregroundStyle(reviewText.count > 1000 ? .red : .secondary)
                                .padding(.trailing, 20)
                        }
                    }

                    Button {
                        viewModel.add(
                            rating: selectedRating,
                            reviewText: reviewText,
                            title: title,
                            subtitle: subtitle,
                            imageUrl: imageUrl,
                            context: modelContext,
                            onDismiss: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    submitted = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    dismiss()
                                }
                            }
                        )
                    } label: {
                        Group {
                            if submitted {
                                Label("Review Submitted!", systemImage: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                            } else {
                                Text("Submit Review")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .fill(buttonColor)
                                .shadow(color: buttonColor.opacity(0.4), radius: 10, x: 0, y: 5)
                        )
                    }
                    .padding(.horizontal, 20)
                    .disabled(!viewModel.canSubmit(rating: selectedRating, reviewText: reviewText))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: submitted)

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Leave a Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

struct StarRatingView: View {
    @Binding var rating: Double

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: rating >= Double(i) ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.orange)
                    .scaleEffect(rating == Double(i) ? 1.15 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: rating)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            rating = rating == Double(i) ? 0 : Double(i)
                        }
                    }
            }
        }
    }
}
#Preview {
    ReviewSheet(
        title: "Dune: Part Two",
        subtitle: "Movie · 2024",
        imageUrl: URL(string: "https://image.tmdb.org/t/p/w92/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg")
    )
    .modelContainer(for: Review.self, inMemory: true)
}
