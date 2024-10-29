import Foundation

struct QuizNavigationData: Hashable {
  let question: Question
  let chapterId: String

  func hash(into hasher: inout Hasher) {
    hasher.combine(question)
    hasher.combine(chapterId)
  }

  static func == (lhs: QuizNavigationData, rhs: QuizNavigationData) -> Bool {
    lhs.question == rhs.question && lhs.chapterId == rhs.chapterId
  }
}
