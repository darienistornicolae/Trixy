import SwiftUI

struct ResourcesView: View {
  @StateObject private var viewModel = ResourcesViewModel()

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading {
          ProgressView()
        } else if !viewModel.resources.isEmpty {
          ScrollView {
            LazyVStack(spacing: 16) {
              ForEach(viewModel.resources) { topic in
                NavigationLink(value: topic) {
                  ResourceCardView(topic: topic)

                }
                .buttonStyle(PlainButtonStyle())
              }
            }
            .padding()
          }
        } else if let error = viewModel.error {
          Text(error)
            .foregroundColor(.red)
        } else {
          EmptyView()
        }
      }
      .navigationTitle("Financial Resources")
      .navigationDestination(for: ResourceTopic.self) { topic in
        ResourceDetailsView(topic: topic)
      }
    }
    .onAppear {
      viewModel.fetchResources()
    }
  }
}

#Preview {
  ResourcesView()
}
