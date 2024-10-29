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

#Preview {
  VStack(spacing: 16) {
    ResourceCardView(
      topic: ResourceTopic(
        title: "Budgeting Basics",
        description: "Learn how to create and maintain a budget that works for your lifestyle. Master the fundamentals of personal finance.",
        iconName: "dollarsign.circle.fill",
        content: [
          ResourceSection(
            title: "Getting Started",
            content: "Start your budgeting journey here."
          )
        ]
      )
    )
    
    ResourceCardView(
      topic: ResourceTopic(
        title: "Smart Investing",
        description: "Discover the power of compound interest and learn how to make your money work for you through smart investment strategies.",
        iconName: "chart.line.uptrend.xyaxis.circle.fill",
        content: [
          ResourceSection(
            title: "Investment Basics",
            content: "Understanding investment fundamentals."
          )
        ]
      )
    )
  }
  .padding()
  .background(Color(.systemGray6))
}
