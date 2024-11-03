import SwiftUI

struct StatisticsCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color
  @Environment(\.colorScheme) private var colorScheme

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
        .fill(color.opacity(colorScheme == .dark ? 0.15 : 0.1))
    )
  }
}
