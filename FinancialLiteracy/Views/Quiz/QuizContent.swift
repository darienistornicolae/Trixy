import SwiftUI

struct QuizContent: View {
  @ObservedObject var viewModel: QuizViewModel
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

        QuestionCard(question: question, viewModel: viewModel)

        VStack(spacing: 16) {
          ForEach(question.options.indices, id: \.self) { index in
            OptionButton(
              text: question.options[index],
              state: buttonState(for: index)
            ) {
              if !viewModel.isAnswered || !viewModel.isCorrect {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                  viewModel.selectedAnswer = index
                }
              }
            }
          }
        }

        if !viewModel.isCorrect {
          SubmitButton(viewModel: viewModel)
        }

        if viewModel.showFeedback && viewModel.isCorrect {
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
    switch (viewModel.showFeedback, index) {
    case (true, question.correctAnswer) where viewModel.isCorrect:
      return .correct
    case (true, viewModel.selectedAnswer) where !viewModel.isCorrect:
      return .wrong
    case (_, viewModel.selectedAnswer):
      return .selected
    default:
      return .default
    }
  }
}
