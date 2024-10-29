import Foundation

@MainActor
final class ChaptersViewModel: ObservableObject {
    @Published private(set) var chapters: [Chapter] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var userProgress: UserProgress?
    
    private let firestoreManager: FirestoreManager<Chapter>
    private let progressManager: FirestoreManager<UserProgress>
    private let userId: String
    
    init(userId: String,
         firestoreManager: FirestoreManager<Chapter> = FirestoreManager(collection: "chapters"),
         progressManager: FirestoreManager<UserProgress> = FirestoreManager(collection: "userProgress")) {
        self.userId = userId
        self.firestoreManager = firestoreManager
        self.progressManager = progressManager
    }
    
    func fetchChapters() async {
        isLoading = true
        error = nil
        
        do {
            // First fetch chapters
            let fetchedChapters = try await firestoreManager.fetch()
            
            // Try to fetch progress, create new if doesn't exist
            let progress: UserProgress
            do {
                progress = try await progressManager.getDocument(id: userId)
            } catch {
                // Create initial progress with first question of first chapter
                progress = UserProgress(
                    userId: userId,
                    chapterId: fetchedChapters[0].id,
                    lastQuestionId: fetchedChapters[0].questions[0].id,
                    completedQuestions: []
                )
                
                let data = try JSONEncoder().encode(progress)
                let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                try await progressManager.createDocument(id: userId, data: dict)
            }
            
            userProgress = progress
            
            // First mark completed questions
            var updatedChapters = fetchedChapters
            for chapterIndex in updatedChapters.indices {
                for questionIndex in updatedChapters[chapterIndex].questions.indices {
                    let question = updatedChapters[chapterIndex].questions[questionIndex]
                    if progress.completedQuestions.contains(question.id) {
                        updatedChapters[chapterIndex].questions[questionIndex].state = .completed
                    }
                }
            }
            
            // Then update unlocked states
            for chapterIndex in updatedChapters.indices {
                let isFirstChapter = chapterIndex == 0
                let previousChapterCompleted = !isFirstChapter && 
                    updatedChapters[chapterIndex - 1].questions.allSatisfy { $0.state == .completed }
                
                for questionIndex in updatedChapters[chapterIndex].questions.indices {
                    if updatedChapters[chapterIndex].questions[questionIndex].state == .completed {
                        continue
                    }
                    
                    let shouldUnlock = (isFirstChapter && questionIndex == 0) ||
                        (questionIndex == 0 && previousChapterCompleted) ||
                        (questionIndex > 0 && updatedChapters[chapterIndex].questions[questionIndex - 1].state == .completed)
                    
                    updatedChapters[chapterIndex].questions[questionIndex].state = shouldUnlock ? .unlocked : .locked
                }
            }
            
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
        
        // Find the first unlocked question in the current chapter
        if let nextQuestion = currentChapter.questions.first(where: { $0.state == .unlocked }) {
            return QuizNavigationData(question: nextQuestion, chapterId: currentChapter.id)
        }
        
        // If no unlocked questions in current chapter, look for the next chapter with unlocked questions
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