import SwiftUI

struct ResourceDetailsView: View {
  let topic: ResourceTopic

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          headerView

          VStack(alignment: .leading, spacing: 12) {
            Text("Table of Contents")
              .font(.title2)
              .fontWeight(.bold)
              .padding(.horizontal)

            ForEach(topic.content) { section in
              Button {
                withAnimation {
                  proxy.scrollTo(section.id, anchor: .top)
                }
              } label: {
                Text(section.title)
                  .font(.body)
                  .foregroundColor(.blue)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding(.vertical, 8)
                  .padding(.horizontal)
              }
            }
          }
          .padding(.vertical)

          contentSection
        }
        .padding(.vertical)
      }
    }
    .navigationTitle(topic.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationView {
    ResourceDetailsView(
      topic: ResourceTopic(
        title: "Budgeting Basics",
        description: "Learn how to create and maintain a budget that works for your lifestyle",
        iconName: "dollarsign.circle.fill",
        content: [
          ResourceSection(
            title: "What is Budgeting?",
            content: "Budgeting is the process of creating a plan to spend your money. This spending plan is called a budget. Creating this spending plan allows you to determine in advance whether you will have enough money to do the things you need to do or would like to do."
          ),
          ResourceSection(
            title: "The 50/30/20 Rule",
            content: "The 50/30/20 budget rule is a simple way to budget that doesn't involve detailed budgeting categories. Instead, you spend 50% of your after-tax income on needs, 30% on wants, and 20% on savings or paying off debt."
          ),
          ResourceSection(
            title: "Getting Started",
            content: "To create a budget, start by tracking your income and expenses for a month. Write down everything you spend money on, from bills to coffee. Then, categorize these expenses into needs, wants, and savings. This will give you a clear picture of your spending habits."
          )
        ]
      )
    )
  }
}

// MARK: Private
private extension ResourceDetailsView {
  var headerView: some View {
    HStack(spacing: 16) {
      Image(systemName: topic.iconName)
        .font(.largeTitle)
      
      VStack(alignment: .leading) {
        Text(topic.title)
          .font(.title)
          .fontWeight(.bold)
        
        Text(topic.description)
          .font(.subheadline)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(.systemBackground))
  }
  
  var contentSection: some View {
    ForEach(topic.content) { section in
      VStack(alignment: .leading, spacing: 12) {
        Text(section.title)
          .font(.title2)
          .fontWeight(.semibold)
        
        Text(section.content)
          .font(.body)
          .foregroundColor(.secondary)
      }
      .padding(.horizontal)
      .id(section.id)
    }
  }
}
