import SwiftUI

struct QuizView: View {
  let question: Question
  let chapterId: String
  @Environment(\.dismiss) private var dismiss
  @StateObject private var quizManager: QuizManager
  @EnvironmentObject private var chaptersManager: ChaptersManager
  @EnvironmentObject private var navigationRouter: NavigationRouter

  init(question: Question, chapterId: String) {
    self.question = question
    self.chapterId = chapterId
    _quizManager = StateObject(wrappedValue: QuizManager(
      question: question,
      chapterId: chapterId,
      userId: AuthManager.shared.currentUserId
    ))
  }

  var body: some View {
    ZStack {
      Color(.systemBackground)
        .ignoresSafeArea()
      
      QuizContent(
        quizManager: quizManager,
        question: question,
        chapterId: chapterId
      )
      
      if quizManager.showSnackbar {
        VStack {
          Spacer()
          Snackbar(
            message: quizManager.isCorrect ? "Awesome! You got it right!" : "Almost there! Try again!",
            isSuccess: quizManager.isCorrect,
            isShowing: $quizManager.showSnackbar
          )
        }
        .transition(.move(edge: .bottom))
      }
    }
    .onChange(of: quizManager.shouldNavigateNext) { shouldNavigate in
      if shouldNavigate {
        Task {
          await chaptersManager.fetchChapters()
        }
      }
    }
    .alert("Need a hint?", isPresented: $quizManager.showAnswerAlert) {
      Button("Show Answer", role: .destructive) {
        quizManager.showCorrectAnswer()
      }
      Button("Try Again", role: .cancel) {
        quizManager.resetAnswer()
      }
    } message: {
      Text("Would you like to see the correct answer or try again?")
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          navigationRouter.popToRoot()
          Task {
            await chaptersManager.fetchChapters()
          }
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(.blue)
        }
      }
    }
  }
}
