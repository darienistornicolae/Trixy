import Foundation

@MainActor
final class ResourcesViewModel: ObservableObject {
  @Published private(set) var resources: [ResourceTopic] = []
  @Published private(set) var isLoading = false
  @Published private(set) var error: String?

  private let firestoreManager: FirestoreManager<ResourceTopic>

  init(firestoreManager: FirestoreManager<ResourceTopic> = FirestoreManager(collection: "resources")) {
    self.firestoreManager = firestoreManager
  }

  func fetchResources() {
    Task {
      isLoading = true
      error = nil

      do {
        resources = try await firestoreManager.fetch()
      } catch {
        self.error = error.localizedDescription
      }

      isLoading = false
    }
  }
}
