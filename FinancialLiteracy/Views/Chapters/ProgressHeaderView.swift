import SwiftUI

struct ProgressHeaderView: View {
    let chapters: [Chapter]
    
    private var totalProgress: Double {
        let completedQuestions = chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.filter { $0.state == .completed }.count
        }
        let totalQuestions = chapters.reduce(0) { sum, chapter in
            sum + chapter.questions.count
        }
        return totalQuestions > 0 ? Double(completedQuestions) / Double(totalQuestions) : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Course Progress")
                        .font(.headline)
                    
                    Text("\(Int(totalProgress * 100))% Complete")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                    
                    Circle()
                        .trim(from: 0, to: totalProgress)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(totalProgress * 100))%")
                        .font(.caption)
                        .bold()
                }
                .frame(width: 60, height: 60)
            }
            
            ProgressView(value: totalProgress)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut, value: totalProgress)
    }
} 
