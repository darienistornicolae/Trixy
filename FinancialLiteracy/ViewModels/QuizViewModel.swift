import Foundation
import SwiftUI

@MainActor
final class QuizViewModel: ObservableObject {
  @Published var selectedAnswer: Int?
  @Published var isAnswered = false
  @Published var isCorrect = false
  @Published var showFeedback = false
  @Published var showSnackbar = false
  @Published var showAnswerAlert = false
  @Published var shouldNavigateNext = false
  @Published private(set) var attempts = 0

  private let question: Question
  private let firestoreManager: FirestoreManager<Chapter>
  private let progressManager: FirestoreManager<UserProgressModel>
  private let chapterId: String
  private let userId: String

  init(question: Question,
       chapterId: String,
       userId: String,
       firestoreManager: FirestoreManager<Chapter> = FirestoreManager(collection: "chapters"),
       progressManager: FirestoreManager<UserProgressModel> = FirestoreManager(collection: "userProgress")) {
    self.question = question
    self.chapterId = chapterId
    self.userId = userId
    self.firestoreManager = firestoreManager
    self.progressManager = progressManager
  }

  func submitAnswer() async {
    guard let selectedAnswer = selectedAnswer else { return }

    isAnswered = true
    isCorrect = selectedAnswer == question.correctAnswer
    showFeedback = true
    attempts += 1

    withAnimation {
      showSnackbar = true
    }

    if isCorrect {
      await saveProgress()
      await updateQuestionState()

      try? await Task.sleep(nanoseconds: 1_500_000_000)
      shouldNavigateNext = true
    } else if attempts == 2 {
      showAnswerAlert = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      withAnimation {
        self.showSnackbar = false
      }
    }
  }

  func resetAnswer() {
    selectedAnswer = nil
    isAnswered = false
    showFeedback = false
  }

  func showCorrectAnswer() {
    selectedAnswer = question.correctAnswer
    isCorrect = true
    showFeedback = true
  }
}

// MARK: Private
private extension QuizViewModel {
  func saveProgress() async {
    do {
      let existingProgress: UserProgressModel
      do {
        existingProgress = try await progressManager.getDocument(id: userId)
      } catch {
        existingProgress = UserProgressModel(
          userId: userId,
          chapterId: chapterId,
          lastQuestionId: question.id,
          completedQuestions: []
        )
      }

      var updatedProgress = existingProgress
      updatedProgress.chapterId = chapterId
      updatedProgress.lastQuestionId = question.id
      if !updatedProgress.completedQuestions.contains(question.id) {
        updatedProgress.completedQuestions.insert(question.id)
      }

      let data = try JSONEncoder().encode(updatedProgress)
      let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

      try await progressManager.updateDocument(id: userId, data: dict)
    } catch {
      print("Error saving progress: \(error)")
    }
  }

  func updateQuestionState() async {
    do {
      let chapter = try await firestoreManager.getDocument(id: chapterId)
      var updatedQuestions = chapter.questions

      guard let questionIndex = updatedQuestions.firstIndex(where: { $0.id == question.id }) else {
        print("Question not found in chapter")
        return
      }

      updatedQuestions[questionIndex].state = .completed

      if questionIndex + 1 < updatedQuestions.count {
        updatedQuestions[questionIndex + 1].state = .unlocked
      }

      let questionsData = try updatedQuestions.map { question -> [String: Any] in
        let data = try JSONEncoder().encode(question)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
          throw NSError(domain: "QuizViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert question to dictionary"])
        }
        return dict
      }

      try await withRetry(maxAttempts: 3) {
        try await firestoreManager.updateDocument(
          id: chapterId,
          data: ["questions": questionsData]
        )
      }
    } catch {
      print("Error updating question state: \(error.localizedDescription)")
    }
  }

  func withRetry<T>(maxAttempts: Int, operation: () async throws -> T) async throws -> T {
    var attempts = 0
    var lastError: Error?
    
    while attempts < maxAttempts {
      do {
        return try await operation()
      } catch {
        attempts += 1
        lastError = error
        if attempts < maxAttempts {
          try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))
        }
      }
    }
    throw lastError ?? NSError(domain: "QuizViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Max retry attempts reached"])
  }
}
