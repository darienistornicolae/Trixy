import SwiftUI

struct NavigationActionButton: View {
  @EnvironmentObject private var chaptersViewModel: ChaptersManager
  let question: Question
  let chapterId: String

  var body: some View {
    if let nextQuestion = nextQuestion {
      NavigationLink(value: QuizNavigationData(question: nextQuestion, chapterId: chapterId)) {
        ActionButton(title: "Next Question", icon: "arrow.right")
      }
    } else if let nextChapter = nextChapter {
      NavigationLink(value: QuizNavigationData(question: nextChapter.questions[0], chapterId: nextChapter.id)) {
        ActionButton(title: "Next Chapter", icon: "arrow.right")
      }
    } else {
      NavigationLink(value: "chapters") {
        ActionButton(title: "Complete!", icon: "checkmark")
      }
    }
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
}
