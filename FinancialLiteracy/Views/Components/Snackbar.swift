import SwiftUI

struct Snackbar: View {
  let message: String
  let isSuccess: Bool
  @Binding var isShowing: Bool

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(isSuccess ? .green : .red)

      Text(message)
        .font(.subheadline)
        .foregroundColor(.white)

      Spacer()

      Button {
        withAnimation {
          isShowing = false
        }
      } label: {
        Image(systemName: "xmark")
          .foregroundColor(.white)
      }
    }
    .padding()
    .background(Color.black.opacity(0.8))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding(.horizontal)
    .transition(.move(edge: .top).combined(with: .opacity))
  }
}
