import SwiftUI
struct PosterPlaceholder: View {
        var body: some View {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemFill))
                .overlay(
                    Image(systemName: "photo")
                        .foregroundStyle(.quaternary)
                        .font(.system(size: 18))
                )
        }
    }
