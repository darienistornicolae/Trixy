import Foundation
import Combine

@MainActor
final class ChaptersManager: ObservableObject {
  @Published var chapters: [Chapter] = []
  @Published var isLoading = false
  @Published private var error: String?
  @Published var userProgress: UserProgressModel?

  private let firestoreManager: FirestoreManager<Chapter>
  private let progressManager: FirestoreManager<UserProgressModel>
  private let userId: String
  private var cancellables = Set<AnyCancellable>()

  init(userId: String,
       firestoreManager: FirestoreManager<Chapter> = FirestoreManager(collection: "chapters"),
       progressManager: FirestoreManager<UserProgressModel> = FirestoreManager(collection: "userProgress")) {
    self.userId = userId
    self.firestoreManager = firestoreManager
    self.progressManager = progressManager

    setupNotifications()
  }

  private func setupNotifications() {
    NotificationCenter.default
      .publisher(for: .chapterUpdated)
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        Task {
          await self?.fetchChapters()
        }
      }
      .store(in: &cancellables)
  }

  func fetchChapters() async {
    isLoading = true
    error = nil

    do {
      let fetchedChapters = try await firestoreManager.fetch()
      let progress = try await fetchOrCreateProgress(with: fetchedChapters)
      userProgress = progress

      var updatedChapters = fetchedChapters
      markCompletedQuestions(in: &updatedChapters, with: progress)
      updateQuestionStates(in: &updatedChapters)

      chapters = updatedChapters
    } catch {
      self.error = error.localizedDescription
    }
    isLoading = false
  }

  func resumeLastQuestion() -> QuizNavigationData? {
    guard let progress = userProgress,
          let currentChapter = chapters.first(where: { $0.id == progress.chapterId }) else {
      return nil
    }

    if let nextQuestion = currentChapter.questions.first(where: { $0.state == .unlocked }) {
      return QuizNavigationData(question: nextQuestion, chapterId: currentChapter.id)
    }

    if let nextChapterIndex = chapters.firstIndex(where: { $0.id == currentChapter.id }).map({ $0 + 1 }),
       nextChapterIndex < chapters.count {
      let nextChapter = chapters[nextChapterIndex]
      if let firstUnlockedQuestion = nextChapter.questions.first(where: { $0.state == .unlocked }) {
        return QuizNavigationData(question: firstUnlockedQuestion, chapterId: nextChapter.id)
      }
    }
    return nil
  }
}

// MARK: Private
private extension ChaptersManager {
  func fetchOrCreateProgress(with chapters: [Chapter]) async throws -> UserProgressModel {
    do {
      return try await progressManager.getDocument(id: userId)
    } catch {
      let initialProgress = UserProgressModel(
        userId: userId,
        chapterId: chapters[0].id,
        lastQuestionId: chapters[0].questions[0].id,
        completedQuestions: []
      )
      
      let data = try JSONEncoder().encode(initialProgress)
      let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
      try await progressManager.createDocument(id: userId, data: dict)
      
      return initialProgress
    }
  }
  
  func markCompletedQuestions(in chapters: inout [Chapter], with progress: UserProgressModel) {
    for chapterIndex in chapters.indices {
      for questionIndex in chapters[chapterIndex].questions.indices {
        let question = chapters[chapterIndex].questions[questionIndex]
        if progress.completedQuestions.contains(question.id) {
          chapters[chapterIndex].questions[questionIndex].state = .completed
        }
      }
    }
  }
  
  func updateQuestionStates(in chapters: inout [Chapter]) {
    for chapterIndex in chapters.indices {
      let isFirstChapter = chapterIndex == 0
      let previousChapterCompleted = !isFirstChapter &&
      chapters[chapterIndex - 1].questions.allSatisfy { $0.state == .completed }
      
      updateQuestionsInChapter(
        at: chapterIndex,
        in: &chapters,
        isFirstChapter: isFirstChapter,
        previousChapterCompleted: previousChapterCompleted
      )
    }
  }
  
  func updateQuestionsInChapter(
    at chapterIndex: Int,
    in chapters: inout [Chapter],
    isFirstChapter: Bool,
    previousChapterCompleted: Bool
  ) {
    for questionIndex in chapters[chapterIndex].questions.indices {
      if chapters[chapterIndex].questions[questionIndex].state == .completed {
        continue
      }
      
      let shouldUnlock = shouldUnlockQuestion(
        at: questionIndex,
        in: chapters[chapterIndex],
        isFirstChapter: isFirstChapter,
        previousChapterCompleted: previousChapterCompleted
      )
      
      chapters[chapterIndex].questions[questionIndex].state = shouldUnlock ? .unlocked : .locked
    }
  }
  
  func shouldUnlockQuestion(
    at index: Int,
    in chapter: Chapter,
    isFirstChapter: Bool,
    previousChapterCompleted: Bool
  ) -> Bool {
    (isFirstChapter && index == 0) ||
    (index == 0 && previousChapterCompleted) ||
    (index > 0 && chapter.questions[index - 1].state == .completed)
  }
}
