import SwiftUI

struct CurrentChapterSection: View {
  @Environment(\.colorScheme) private var colorScheme
  let chapter: Chapter

  var body: some View {
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
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .clipShape(Capsule())
        }

        let completedCount = chapter.questions.filter { $0.state == .completed }.count
        ProgressView(value: Double(completedCount), total: Double(chapter.questions.count))
          .tint(.blue)
          .background(Color.blue.opacity(0.2))
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }
      .padding()
      .background(cardBackground)
    }
    .padding(.horizontal)
  }
}

// MARK: Private
private extension CurrentChapterSection {
  var cardBackground: some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(Color(uiColor: .systemBackground))
      .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.05), radius: 8)
  }
}
