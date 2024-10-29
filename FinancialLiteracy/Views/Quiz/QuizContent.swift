import SwiftUI

struct QuizContent: View {
  @ObservedObject var viewModel: QuizViewModel
  let question: Question
  let chapterId: String

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        QuestionCard(question: question, viewModel: viewModel)

        VStack(spacing: 16) {
          ForEach(question.options.indices, id: \.self) { index in
            OptionButton(
              text: question.options[index],
              isSelected: viewModel.selectedAnswer == index,
              isCorrect: viewModel.showFeedback && viewModel.isCorrect && index == question.correctAnswer,
              isWrong: viewModel.showFeedback && viewModel.selectedAnswer == index && !viewModel.isCorrect
            ) {
              if !viewModel.isAnswered || !viewModel.isCorrect {
                viewModel.selectedAnswer = index
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
      .padding()
    }
  }
}
