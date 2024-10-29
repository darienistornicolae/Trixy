import SwiftUI

struct ChaptersView: View {
  @StateObject private var viewModel = ChaptersViewModel(userId: AuthManager.shared.currentUserId)
  @State private var expandedChapter: String?

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isLoading {
          ProgressView()
        } else if !viewModel.chapters.isEmpty {
          ScrollView {
            VStack(spacing: 16) {
              ProgressHeaderView(chapters: viewModel.chapters)
                .padding(.horizontal)
              
              if let navigationData = viewModel.resumeLastQuestion() {
                NavigationLink(value: navigationData) {
                  resumeButton()
                }
                .padding(.horizontal)
              }

              LazyVStack(spacing: 16) {
                ForEach(viewModel.chapters) { chapter in
                  ChapterCardView(
                    chapter: chapter,
                    isExpanded: expandedChapter == chapter.id
                  ) {
                    withAnimation {
                      expandedChapter = expandedChapter == chapter.id ? nil : chapter.id
                    }
                  }
                }
              }
              .padding(.horizontal)
            }
          }
          .background(Color(.systemGroupedBackground))
        } else {
          Text("No chapters available.")
            .font(.headline)
            .foregroundColor(.gray)
            .padding()
        }
      }
      .navigationTitle("Learning Chapters")
      .navigationDestination(for: QuizNavigationData.self) { navigationData in
        QuizView(
          question: navigationData.question,
          chapterId: navigationData.chapterId
        )
        .environmentObject(viewModel)
      }
    }
    .task {
      await viewModel.fetchChapters()
    }
  }
}

#Preview {
  ChaptersView()
}

private extension ChaptersView {
  private func resumeButton() -> some View {
    HStack {
      Image(systemName: "play.circle.fill")
        .foregroundColor(.blue)
        .font(.title2)
      
      VStack(alignment: .leading, spacing: 4) {
        Text("Continue Learning")
          .font(.headline)
        
        Text("Resume where you left off")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .foregroundColor(.gray)
        .font(.caption)
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}
