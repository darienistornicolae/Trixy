import SwiftUI

struct HomeView: View {
  @ObservedObject private var chaptersManager = ChaptersManager(userId: AuthManager.shared.currentUserId)
  @StateObject private var navigationRouter = NavigationRouter()
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    NavigationStack(path: $navigationRouter.path) {
      Group {
        if chaptersManager.isLoading {
          ProgressView()
        } else if !chaptersManager.chapters.isEmpty {
          ScrollView {
            VStack(spacing: 24) {
              statsOverview

              if let currentChapter = getCurrentChapter() {
                CurrentChapterSection(chapter: currentChapter)
                  .transition(.move(edge: .trailing))
              }

              if let navigationData = chaptersManager.resumeLastQuestion() {
                NavigationLink(value: navigationData) {
                  ActionButton(
                    title: "Continue Learning",
                    icon: "play.circle.fill"
                  )
                }
                .padding(.horizontal)
              }
            }
            .padding(.vertical)
          }
          .background(Color(uiColor: .systemGroupedBackground))
        } else {
          Text("No chapters available.")
            .font(.headline)
            .foregroundColor(.secondary)
            .padding()
        }
      }
      .navigationTitle("Home")
      .navigationDestination(for: QuizNavigationData.self) { navigationData in
        QuizView(
          question: navigationData.question,
          chapterId: navigationData.chapterId
        )
        .environmentObject(chaptersManager)
        .environmentObject(navigationRouter)
      }
    }
    .task {
      await chaptersManager.fetchChapters()
    }
  }
}

// MARK: - Private
private extension HomeView {
  var statsOverview: some View {
    VStack(spacing: 20) {
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text("Overall Progress")
            .font(.subheadline)
            .foregroundColor(.secondary)
          Spacer()
          Text("\(Int(totalProgress * 100))%")
            .font(.subheadline.bold())
            .foregroundColor(.blue)
        }

        ProgressView(value: totalProgress)
          .tint(.blue)
          .background(Color.blue.opacity(0.2))
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }
      .padding(.horizontal)
      
      HStack(spacing: 12) {
        StatisticsCard(
          title: "Total Questions",
          value: "\(totalQuestions)",
          icon: "book.fill",
          color: .blue
        )
        
        StatisticsCard(
          title: "Completed",
          value: "\(completedQuestions)",
          icon: "checkmark.circle.fill",
          color: .green
        )
        
        StatisticsCard(
          title: "Wrong Attempts",
          value: "\(chaptersManager.userProgress?.wrongAttempts.values.reduce(0, +) ?? 0)",
          icon: "xmark.circle.fill",
          color: .red
        )
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(cardBackground)
  }

  var cardBackground: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .systemBackground))
      .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8)
  }

  var totalProgress: Double {
    let completedQuestions = chaptersManager.chapters.reduce(0) { sum, chapter in
      sum + chapter.questions.filter { $0.state == .completed }.count
    }
    let totalQuestions = chaptersManager.chapters.reduce(0) { sum, chapter in
      sum + chapter.questions.count
    }
    return totalQuestions > 0 ? Double(completedQuestions) / Double(totalQuestions) : 0
  }

  var completedQuestions: Int {
    chaptersManager.chapters.reduce(0) { sum, chapter in
      sum + chapter.questions.filter { $0.state == .completed }.count
    }
  }

  var totalQuestions: Int {
    chaptersManager.chapters.reduce(0) { sum, chapter in
      sum + chapter.questions.count
    }
  }

  func getCurrentChapter() -> Chapter? {
    guard let progress = chaptersManager.userProgress else { return chaptersManager.chapters.first }
    return chaptersManager.chapters.first { $0.id == progress.chapterId }
  }
}
