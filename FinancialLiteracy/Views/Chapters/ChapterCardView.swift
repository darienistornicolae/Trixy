import SwiftUI

struct ChapterCardView: View {
    let chapter: Chapter
    let isExpanded: Bool
    let onTap: () -> Void
    
    private var completedQuestions: Int {
        chapter.questions.filter { $0.state == .completed }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onTap) {
                HStack {
                    Text(chapter.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(completedQuestions)/\(chapter.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.easeInOut, value: isExpanded)
                }
            }
            
            if isExpanded {
                VStack(spacing: 1) {
                    ForEach(Array(chapter.questions.enumerated()), id: \.element.id) { index, question in
                        NavigationLink(value: QuizNavigationData(question: question, chapterId: chapter.id)) {
                            QuestionRowView(question: question, index: index)
                        }
                        .disabled(question.state == .locked)
                    }
                }
                .transition(.opacity.animation(.easeInOut))
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
} 