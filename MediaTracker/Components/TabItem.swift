import SwiftUI

struct TabBarPill: View {
    let tabs: [TabItem]
    @Binding var selectedId: String
    @Namespace private var tabAnimation
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tabs) { tab in
                        TabBarPillItem(
                            tab: tab,
                            isSelected: selectedId == tab.id,
                            namespace: tabAnimation
                        )
                        .id(tab.id)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                selectedId = tab.id
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .background(.ultraThinMaterial)
            .onChange(of: selectedId) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    proxy.scrollTo(selectedId, anchor: .center)
                }
            }
        }
    }
}

struct TabBarPillItem: View {
    let tab: TabItem
    let isSelected: Bool
    var namespace: Namespace.ID
    
    var body: some View {
        ZStack {
            if isSelected {
                Capsule()
                    .fill(tab.color.opacity(0.85))
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.25), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.75
                            )
                    }
                    .shadow(color: tab.color.opacity(0.4), radius: 8, x: 0, y: 4)
                    .matchedGeometryEffect(id: "selectedPill", in: namespace)
            } else {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                    }
            }
            
            HStack(spacing: 5) {
                if let icon = tab.icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                }
                Text(tab.title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
            }
            .foregroundStyle(isSelected ? .white : Color(.label).opacity(0.75))
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
        }
        .fixedSize()
        .contentShape(Capsule())
    }
}
