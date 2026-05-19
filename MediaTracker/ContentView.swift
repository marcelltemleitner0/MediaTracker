import SwiftData
import SwiftUI

struct ContentView: View {
  @State private var searchText: String = ""
  @StateObject private var searchViewModel = SearchViewModel()

  var body: some View {
    TabView {
      Tab("Home", systemImage: "house") {
        HomeView()
      }

      Tab("My Reviews", systemImage: "star.fill") {
        ReviewView()
      }

      Tab("Library", systemImage: "building.columns") {
        ArchiveView()
      }

      Tab("Search", systemImage: "magnifyingglass", role: .search) {
        NavigationStack {
          SearchView(viewModel: searchViewModel)
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
      ArchiveItem.self,
    ])
}
