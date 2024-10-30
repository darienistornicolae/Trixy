import SwiftUI

struct Snackbar: View {
  let message: String
  let isSuccess: Bool
  @Binding var isShowing: Bool
  @Environment(\.colorScheme) private var colorScheme

  private var backgroundColor: Color {
    isSuccess ? Color.green : Color.red
  }

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
        .font(.system(size: 20, weight: .semibold))
        .foregroundColor(.white)

      Text(message)
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.white)

      Spacer()

      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
          isShowing = false
        }
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(.white.opacity(0.9))
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 12)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(backgroundColor)
    )
    .padding(.horizontal)
    .transition(
      .asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .opacity
      )
    )
  }
}

#Preview {
  VStack {
    Snackbar(
      message: "🎉 Awesome! You got it right!",
      isSuccess: true,
      isShowing: .constant(true)
    )

    Snackbar(
      message: "🤔 Almost there! Try again!",
      isSuccess: false,
      isShowing: .constant(true)
    )
  }
}
