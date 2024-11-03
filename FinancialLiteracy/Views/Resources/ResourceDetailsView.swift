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
