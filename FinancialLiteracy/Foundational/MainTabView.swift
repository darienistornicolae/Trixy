import Foundation
import SwiftUI

struct MainTabView: View {
  @State private var selectedTab = 0
  
  var body: some View {
    TabView(selection: $selectedTab) {
      Text("Home View")
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }
        .tag(0)

      ChaptersView()
        .tabItem {
          Label("Chapters", systemImage: "book.fill")
        }
        .tag(1)

      ResourcesView()
        .tabItem {
          Label("Resources", systemImage: "folder.fill")
        }
        .tag(2)

      Text("Profile View")
        .tabItem {
          Label("Profile", systemImage: "person.fill")
        }
        .tag(3)
    }
  }
}
