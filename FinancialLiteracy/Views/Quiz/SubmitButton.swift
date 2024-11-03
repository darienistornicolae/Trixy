import SwiftUI

struct SubmitButton: View {
  @ObservedObject var viewModel: QuizManager

  var body: some View {
    Button {
      if viewModel.isAnswered && !viewModel.isCorrect {
        viewModel.resetAnswer()
      } else {
        Task {
          await viewModel.submitAnswer()
        }
      }
    } label: {
      Text(viewModel.isAnswered && !viewModel.isCorrect ? "Try Again" : "Submit Answer")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(viewModel.selectedAnswer != nil ? Color.blue : Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .disabled(viewModel.selectedAnswer == nil)
  }
}
