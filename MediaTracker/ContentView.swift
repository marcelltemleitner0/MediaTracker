import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @StateObject private var searchViewModel = SearchViewModel()
    @Environment(\.modelContext) private var modelContext

    private var archiveViewModel: ArchiveViewModel {
        ArchiveViewModel(modelContext: modelContext)
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }

            Tab("Reviews", systemImage: "star.fill") {
                ReviewView()
            }

            Tab("Archive", systemImage: "building.columns") {
                ArchiveView(modelContext: modelContext)            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    SearchView(viewModel: searchViewModel, archiveViewModel: archiveViewModel)
                        .navigationTitle("Search").navigationBarTitleDisplayMode(.large)
                }
                .searchable(text: $searchText, placement: .toolbar, prompt: Text("Movies, series, anime…"))
                .onChange(of: searchText) { _, newValue in
                    searchViewModel.search(query: newValue)
                }
                .onSubmit(of: .search) {
                    searchViewModel.search(query: searchText)
                }
            }
        }.tint(.red)
    }
}

#Preview("ContentView") {
    ContentView()
        .modelContainer(for: [
            Review.self,
            Archive.self,
        ])
}
