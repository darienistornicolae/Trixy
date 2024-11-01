import Foundation

struct UserProgressModel: Codable {
  let userId: String
  var chapterId: String
  var lastQuestionId: String
  var completedQuestions: Set<String>
  var wrongAttempts: [String: Int]

  init(userId: String, chapterId: String, lastQuestionId: String, completedQuestions: Set<String> = [], wrongAttempts: [String: Int] = [:]) {
    self.userId = userId
    self.chapterId = chapterId
    self.lastQuestionId = lastQuestionId
    self.completedQuestions = completedQuestions
    self.wrongAttempts = wrongAttempts
  }
}
