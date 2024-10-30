import SwiftUI

struct OptionButton: View {
  let text: String
  var state: State
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      HStack {
        Text(text)
          .font(.body)
          .fontWeight(.medium)
          .multilineTextAlignment(.leading)
          .foregroundColor(state.textColor)
        
        Spacer()
        
        state.icon
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(state.backgroundColor)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(state.borderColor,
                      lineWidth: state == .selected ? 2 : 1)
          )
      )
    }
    .buttonStyle(.plain)
  }
}

extension OptionButton {
  enum State: Equatable {
    case correct
    case wrong
    case selected
    case `default`
    
    var backgroundColor: Color {
      switch self {
      case .correct: return .green.opacity(0.1)
      case .wrong: return .red.opacity(0.1)
      case .selected: return .blue.opacity(0.1)
      case .default: return .clear
      }
    }
    
    var borderColor: Color {
      switch self {
      case .correct: return .green
      case .wrong: return .red
      case .selected: return .blue
      case .default: return .gray.opacity(0.3)
      }
    }
    
    var textColor: Color {
      switch self {
      case .correct: return .green
      case .wrong: return .red
      case .selected: return .blue
      case .default: return .primary
      }
    }
    
    @ViewBuilder
    var icon: some View {
      switch self {
      case .correct:
        Image(systemName: "checkmark.circle.fill")
          .foregroundColor(.green)
      case .wrong:
        Image(systemName: "xmark.circle.fill")
          .foregroundColor(.red)
      case .selected, .default:
        EmptyView()
      }
    }
  }
}

#Preview {
  OptionButton(text: "Option", state: .default) {}
  OptionButton(text: "Option", state: .correct) {}
  OptionButton(text: "Option", state: .wrong) {}
}
