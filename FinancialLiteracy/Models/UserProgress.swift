struct UserProgress: Codable {
    let userId: String
    var chapterId: String
    var lastQuestionId: String
    var completedQuestions: Set<String>
    
    init(userId: String, chapterId: String, lastQuestionId: String, completedQuestions: Set<String> = []) {
        self.userId = userId
        self.chapterId = chapterId
        self.lastQuestionId = lastQuestionId
        self.completedQuestions = completedQuestions
    }
} 
