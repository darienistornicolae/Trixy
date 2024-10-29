import Foundation

enum QuestionState: String, Codable {
    case locked
    case unlocked
    case completed
}

struct Question: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let questionText: String
    let options: [String]
    let correctAnswer: Int
    var state: QuestionState
    
    init(id: String = UUID().uuidString,
         title: String,
         questionText: String,
         options: [String],
         correctAnswer: Int,
         state: QuestionState = .locked) {
        self.id = id
        self.title = title
        self.questionText = questionText
        self.options = options
        self.correctAnswer = correctAnswer
        self.state = state
    }
}

struct Chapter: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    var questions: [Question]
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String,
         questions: [Question]) {
        self.id = id
        self.title = title
        self.description = description
        self.questions = questions
    }
} 
