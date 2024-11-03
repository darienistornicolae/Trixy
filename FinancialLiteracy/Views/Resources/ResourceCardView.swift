import SwiftUI

struct ResourceCardView: View {
  let topic: ResourceTopic

  private var cardColor: Color {
    switch topic.iconName {
    case "dollarsign.circle.fill": return .blue
    case "banknote.fill": return .green
    case "chart.line.uptrend.xyaxis": return .purple
    case "creditcard.fill": return .orange
    default: return .blue
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack(spacing: 12) {
        Image(systemName: topic.iconName)
          .font(.system(size: 24, weight: .semibold))
          .foregroundColor(.white)
          .frame(width: 32)
        
        Text(topic.title)
          .font(.system(size: 20, weight: .bold))
          .foregroundColor(.white)
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .foregroundColor(.white.opacity(0.8))
          .font(.system(size: 14, weight: .bold))
      }
      
      Text(topic.description)
        .font(.system(size: 15, weight: .regular))
        .foregroundColor(.white.opacity(0.9))
        .lineLimit(3)
        .lineSpacing(4)
    }
    .padding(.vertical, 20)
    .padding(.horizontal, 16)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(
          LinearGradient(
            gradient: Gradient(
              colors: [
                cardColor,
                cardColor.opacity(0.8)
              ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
    )
  }
}
