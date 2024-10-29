import SwiftUI

struct QuizView: View {
  let question: Question
  let chapterId: String
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: QuizViewModel
  @EnvironmentObject private var chaptersViewModel: ChaptersViewModel

  init(question: Question, chapterId: String) {
    self.question = question
    self.chapterId = chapterId
    _viewModel = StateObject(wrappedValue: QuizViewModel(
      question: question,
      chapterId: chapterId,
      userId: AuthManager.shared.currentUserId
    ))
  }

  var body: some View {
    ZStack {
      QuizContent(
        viewModel: viewModel,
        question: question,
        chapterId: chapterId
      )

      if viewModel.showSnackbar {
        VStack {
          Spacer()
          Snackbar(
            message: viewModel.isCorrect ? "Correct! Well done!" : "That's not quite right. Try again!",
            isSuccess: viewModel.isCorrect,
            isShowing: $viewModel.showSnackbar
          )
        }
        .transition(.move(edge: .bottom))
      }
    }
    .onChange(of: viewModel.shouldNavigateNext) { shouldNavigate in
      if shouldNavigate {
        Task {
          await chaptersViewModel.fetchChapters()
        }
      }
    }
    .alert("Need a hint?", isPresented: $viewModel.showAnswerAlert) {
      Button("Show Answer", role: .destructive) {
        viewModel.showCorrectAnswer()
      }
      Button("Try Again", role: .cancel) {
        viewModel.resetAnswer()
      }
    } message: {
      Text("Would you like to see the correct answer or try again?")
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(.blue)
        }
      }
    }
  }
}
