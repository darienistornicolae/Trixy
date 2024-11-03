import SwiftUI

struct QuizContent: View {
  @ObservedObject var quizManager: QuizManager
  let question: Question
  let chapterId: String

  var body: some View {
    ScrollView {
      VStack(spacing: 32) {
        Text(question.title)
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)

        QuestionCard(question: question, viewModel: quizManager)

        VStack(spacing: 16) {
          ForEach(question.options.indices, id: \.self) { index in
            OptionButton(
              text: question.options[index],
              state: buttonState(for: index)
            ) {
              if !quizManager.isAnswered || !quizManager.isCorrect {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                  quizManager.selectedAnswer = index
                }
              }
            }
          }
        }

        if !quizManager.isCorrect {
          SubmitButton(viewModel: quizManager)
        }

        if quizManager.showFeedback && quizManager.isCorrect {
          NavigationActionButton(question: question, chapterId: chapterId)
        }
      }
      .padding(.horizontal)
      .padding(.vertical, 24)
    }
  }
}

// MARK: Private
private extension QuizContent {
  private func buttonState(for index: Int) -> OptionButton.State {
    switch (quizManager.showFeedback, index) {
    case (true, question.correctAnswer) where quizManager.isCorrect:
      return .correct
    case (true, quizManager.selectedAnswer) where !quizManager.isCorrect:
      return .wrong
    case (_, quizManager.selectedAnswer):
      return .selected
    default:
      return .default
    }
  }
}
