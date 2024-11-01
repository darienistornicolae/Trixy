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
  @Published var nextNavigationData: QuizNavigationData?

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

      if let nextData = await getNextQuestion() {
        nextNavigationData = nextData
      }

      try? await Task.sleep(nanoseconds: 1_500_000_000)
      shouldNavigateNext = true
    } else {
      await updateWrongAttempts()
      if attempts == 2 {
        showAnswerAlert = true
      }
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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

  private func getNextQuestion() async -> QuizNavigationData? {
    do {
      let chapter = try await firestoreManager.getDocument(id: chapterId)
      guard let currentIndex = chapter.questions.firstIndex(where: { $0.id == question.id }) else { return nil }
      
      if currentIndex + 1 < chapter.questions.count {
        let nextQuestion = chapter.questions[currentIndex + 1]
        return QuizNavigationData(question: nextQuestion, chapterId: chapterId)
      }
      
      let chapters = try await firestoreManager.fetch()
      guard let chapterIndex = chapters.firstIndex(where: { $0.id == chapterId }),
            chapterIndex + 1 < chapters.count else { return nil }
      
      let nextChapter = chapters[chapterIndex + 1]
      guard let firstQuestion = nextChapter.questions.first else { return nil }
      
      return QuizNavigationData(question: firstQuestion, chapterId: nextChapter.id)
    } catch {
      print("Error getting next question: \(error)")
      return nil
    }
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

      let updatedChapter = Chapter(
        id: chapter.id,
        title: chapter.title,
        description: chapter.description,
        questions: updatedQuestions
      )
      
      let data = try JSONEncoder().encode(updatedChapter)
      guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        throw NSError(domain: "QuizViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode chapter"])
      }

      try await withRetry(maxAttempts: 3) {
        try await firestoreManager.updateDocument(id: chapterId, data: dict)
      }
      
      NotificationCenter.default.post(name: .chapterUpdated, object: nil)
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

  private func updateWrongAttempts() async {
    do {
      var progress = try await progressManager.getDocument(id: userId)
      progress.wrongAttempts[question.id, default: 0] += 1
      
      let data = try JSONEncoder().encode(progress)
      let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
      try await progressManager.updateDocument(id: userId, data: dict)
    } catch {
      print("Error updating wrong attempts: \(error)")
    }
  }
}
