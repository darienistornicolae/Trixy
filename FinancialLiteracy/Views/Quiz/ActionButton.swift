import SwiftUI

struct ActionButton: View {
  let title: String
  let icon: String

  var body: some View {
    HStack {
      Text(title)
        .font(.headline)
      Image(systemName: icon)
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.blue)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

#Preview {
  ActionButton(title: "Something", icon: "chevron.right")
}
