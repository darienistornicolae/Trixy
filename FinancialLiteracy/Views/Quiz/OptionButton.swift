import SwiftUI

struct OptionButton: View {
  let text: String
  let isSelected: Bool
  let isCorrect: Bool
  let isWrong: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        Text(text)
          .font(.body)
          .multilineTextAlignment(.leading)

        Spacer()

        if isCorrect {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.green)
        } else if isWrong {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.red)
        }
      }
    }
    .padding(.vertical, 8)
    .padding(.horizontal, 16)
    .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

