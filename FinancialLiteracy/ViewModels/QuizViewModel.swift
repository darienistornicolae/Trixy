import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var selectedAnswer: Int?
    @Published private(set) var isAnswered = false
    @Published private(set) var error: String?
    @Published private(set) var isCorrect = false
    @Published private(set) var showFeedback = false
    
    private let question: Question
    private let firestoreManager: FirestoreManager<Chapter>
    private let progressManager: FirestoreManager<UserProgress>
    private let chapterId: String
    private let userId: String
    
    init(question: Question,
         chapterId: String,
         userId: String,
         firestoreManager: FirestoreManager<Chapter> = FirestoreManager(collection: "chapters"),
         progressManager: FirestoreManager<UserProgress> = FirestoreManager(collection: "userProgress")) {
        self.question = question
        self.chapterId = chapterId
        self.userId = userId
        self.firestoreManager = firestoreManager
        self.progressManager = progressManager
    }
    
    func checkAnswer(_ index: Int) async {
        selectedAnswer = index
        isAnswered = true
        isCorrect = index == question.correctAnswer
        showFeedback = true
        
        if isCorrect {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.updateQuestionState() }
                group.addTask { await self.saveProgress() }
            }
        }
    }
    
    private func saveProgress() async {
        do {
            // Fetch existing progress or create new
            let existingProgress: UserProgress
            do {
                existingProgress = try await progressManager.getDocument(id: userId)
            } catch {
                existingProgress = UserProgress(
                    userId: userId,
                    chapterId: chapterId,
                    lastQuestionId: question.id,
                    completedQuestions: []
                )
            }
            
            // Update progress
            var updatedProgress = existingProgress
            updatedProgress.completedQuestions.insert(question.id)
            updatedProgress.lastQuestionId = question.id
            updatedProgress.chapterId = chapterId
            
            let data = try JSONEncoder().encode(updatedProgress)
            let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            
            do {
                try await progressManager.updateDocument(id: userId, data: dict)
            } catch {
                try await progressManager.createDocument(id: userId, data: dict)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func updateQuestionState() async {
        do {
            let chapter = try await firestoreManager.getDocument(id: chapterId)
            var updatedQuestions = chapter.questions
            
            guard let questionIndex = updatedQuestions.firstIndex(where: { $0.id == question.id }) else {
                return
            }
            
            updatedQuestions[questionIndex].state = .completed
            
            if questionIndex + 1 < updatedQuestions.count {
                updatedQuestions[questionIndex + 1].state = .unlocked
            }
            
            let questionsData = try updatedQuestions.map { question -> [String: Any] in
                let data = try JSONEncoder().encode(question)
                return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
            }
            
            try await firestoreManager.updateDocument(
                id: chapterId,
                data: ["questions": questionsData]
            )
        } catch {
            self.error = error.localizedDescription
        }
    }
} 
