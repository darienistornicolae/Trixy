import SwiftUI

struct QuestionCard: View {
  let question: Question
  @ObservedObject var viewModel: QuizManager

  var body: some View {
    Text(question.questionText)
      .font(.title2)
      .multilineTextAlignment(.center)
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}
