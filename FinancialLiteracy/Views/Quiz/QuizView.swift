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
    
    private var nextQuestion: Question? {
        guard let chapter = chaptersViewModel.chapters.first(where: { $0.id == chapterId }),
              let currentIndex = chapter.questions.firstIndex(where: { $0.id == question.id }),
              currentIndex + 1 < chapter.questions.count
        else { return nil }
        
        return chapter.questions[currentIndex + 1]
    }
    
    private var nextChapter: Chapter? {
        guard let currentChapterIndex = chaptersViewModel.chapters.firstIndex(where: { $0.id == chapterId }),
              currentChapterIndex + 1 < chaptersViewModel.chapters.count
        else { return nil }
        
        return chaptersViewModel.chapters[currentChapterIndex + 1]
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(question.questionText)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
            
            ForEach(question.options.indices, id: \.self) { index in
                Button {
                    Task {
                        await viewModel.checkAnswer(index)
                    }
                } label: {
                    Text(question.options[index])
                        .font(.body)
                        .foregroundColor(getOptionTextColor(for: index))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(getOptionBackgroundColor(for: index))
                        )
                }
                .disabled(viewModel.isAnswered)
            }
            
            if viewModel.showFeedback {
                Text(viewModel.isCorrect ? "Correct!" : "Try again")
                    .font(.headline)
                    .foregroundColor(viewModel.isCorrect ? .green : .red)
                
                if viewModel.isCorrect {
                    NavigationActionButton()
                }
            }
        }
        .padding()
        .navigationTitle(question.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.isAnswered) { _ in
            if viewModel.isAnswered {
                Task {
                    await chaptersViewModel.fetchChapters()
                }
            }
        }
        .onChange(of: viewModel.isCorrect) { isCorrect in
            if isCorrect {
                Task {
                    await chaptersViewModel.fetchChapters()
                }
            }
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
    
    @ViewBuilder
    private func NavigationActionButton() -> some View {
        if let nextQuestion = nextQuestion {
            NavigationLink(value: QuizNavigationData(question: nextQuestion, chapterId: chapterId)) {
                Text("Next Question")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } else if let nextChapter = nextChapter {
            NavigationLink(value: QuizNavigationData(question: nextChapter.questions[0], chapterId: nextChapter.id)) {
                Text("Start Next Chapter")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button("Complete Course") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private func getOptionTextColor(for index: Int) -> Color {
        guard viewModel.showFeedback else {
            return viewModel.selectedAnswer == index ? .white : .primary
        }
        
        if index == question.correctAnswer {
            return .white
        }
        return viewModel.selectedAnswer == index ? .white : .primary
    }
    
    private func getOptionBackgroundColor(for index: Int) -> Color {
        guard viewModel.showFeedback else {
            return viewModel.selectedAnswer == index ? .blue : Color(.systemGray6)
        }
        
        if index == question.correctAnswer {
            return .green
        }
        return viewModel.selectedAnswer == index ? .red : Color(.systemGray6)
    }
} 
