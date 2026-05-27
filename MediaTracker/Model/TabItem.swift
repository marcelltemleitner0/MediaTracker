import SwiftUI
struct TabItem: Identifiable, Equatable {
    let id: String
    let title: String
    var icon: String? = nil
    var color: Color = .red
    
    init(_ title: String, icon: String? = nil, color: Color = .red) {
        self.id = title
        self.title = title
        self.icon = icon
        self.color = color
    }
}
