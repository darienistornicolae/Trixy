import SwiftUI

struct HomeView: View {
    @ObservedObject private var viewModel = ChaptersViewModel(userId: AuthManager.shared.currentUserId)
    @StateObject private var navigationRouter = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.chapters.isEmpty {
                    ScrollView {
                        VStack(spacing: 24) {
                            statsOverview
                            
                            if let currentChapter = getCurrentChapter() {
                                currentChapterSection(chapter: currentChapter)
                                    .transition(.move(edge: .trailing))
                            }
                            
                            if let navigationData = viewModel.resumeLastQuestion() {
                                NavigationLink(value: navigationData) {
                                    continueButton
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    Text("No chapters available.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: QuizNavigationData.self) { navigationData in
                QuizView(
                    question: navigationData.question,
                    chapterId: navigationData.chapterId
                )
                .environmentObject(viewModel)
                .environmentObject(navigationRouter)
            }
        }
        .task {
            await viewModel.fetchChapters()
        }
    }
    
    private func getCurrentChapter() -> Chapter? {
        guard let progress = viewModel.userProgress else { return viewModel.chapters.first }
        return viewModel.chapters.first { $0.id == progress.chapterId }
    }
}

// MARK: - View Components
private extension HomeView {
    var statsOverview: some View {
        VStack(spacing: 20) {
            // Progress Bar
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
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding(.horizontal)
            
            // Statistics Cards
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
                    value: "\(viewModel.userProgress?.wrongAttempts.values.reduce(0, +) ?? 0)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
    
    var totalProgress: Double {
        let completedQuestions = viewModel.chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.filter { $0.state == .completed }.count
        }
        let totalQuestions = viewModel.chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.count
        }
        return totalQuestions > 0 ? Double(completedQuestions) / Double(totalQuestions) : 0
    }
    
    var completedQuestions: Int {
        viewModel.chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.filter { $0.state == .completed }.count
        }
    }
    
    var totalQuestions: Int {
        viewModel.chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.count
        }
    }
    
    func currentChapterSection(chapter: Chapter) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Chapter")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chapter.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(chapter.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(chapter.questions.filter { $0.state == .completed }.count)/\(chapter.questions.count)")
                        .font(.caption)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                
                let completedCount = chapter.questions.filter { $0.state == .completed }.count
                ProgressView(value: Double(completedCount), total: Double(chapter.questions.count))
                    .tint(.blue)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }
    
    var continueButton: some View {
        HStack {
            Image(systemName: "play.circle.fill")
                .font(.title2)
            
            Text("Continue Learning")
                .font(.headline)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatisticsCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    HomeView()
}