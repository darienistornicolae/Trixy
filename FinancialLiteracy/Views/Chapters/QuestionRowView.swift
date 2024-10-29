import SwiftUI

struct QuestionRowView: View {
  let question: Question
  let index: Int

  private var stateIcon: String {
    switch question.state {
    case .locked: return "lock.circle.fill"
    case .unlocked: return "questionmark.circle.fill"
    case .completed: return "checkmark.circle.fill"
    }
  }

  private var stateColor: Color {
    switch question.state {
    case .locked: return .red
    case .unlocked: return .yellow
    case .completed: return .green
    }
  }

  var body: some View {
    HStack {
      Text("\(index + 1). \(question.title)")
        .font(.subheadline)
        .foregroundColor(question.state == .locked ? .gray : .primary)
      
      Spacer()
      
      Image(systemName: stateIcon)
        .foregroundColor(stateColor)
        .font(.system(size: 16, weight: .semibold))
    }
    .padding(.vertical, 8)
    .opacity(question.state == .locked ? 0.5 : 1.0)
  }
}
