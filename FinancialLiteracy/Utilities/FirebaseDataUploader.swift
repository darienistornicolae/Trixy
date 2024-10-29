import Foundation

@MainActor
final class FirebaseDataUploader {
  private let firestoreManager: FirestoreManager<Chapter>

  init(firestoreManager: FirestoreManager<Chapter> = FirestoreManager(collection: "chapters")) {
    self.firestoreManager = firestoreManager
  }

  func uploadSampleData() async {
    do {
      try await firestoreManager.uploadMultiple(SampleData.chapters)
      print("Successfully uploaded sample chapters data")
    } catch {
      print("Error uploading sample data: \(error.localizedDescription)")
    }
  }
}
